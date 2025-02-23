@@ocamldoc("A Functor for creating a React hook for executing a Field")
module Make = (F: Field.T) => {
  type ret = Form.t<F.t, F.actions<()>>
  let use = (. ~context: F.context, ~init: option<F.input>, ~validateInit): ret => {
    let (first, dyn, _set, _validate) = React.useMemo0( () => {
      let set =
        init
        ->Option.map(Rxjs.Subject.make)
        ->Option.or(Rxjs.Subject.makeEmpty())

      let validate = Rxjs.Subject.makeEmpty()

      let {first, init, dyn} = F.makeDyn(context, init, set->Rxjs.toObservable, validate->Rxjs.toObservable->Some)

      let dyn =
        [ init->Dynamic.return
        , dyn
        ]
        ->Rxjs.concatArray
        ->Dynamic.switchSequence

      (first, dyn, set, validate)
    })


    let (close, setclose) = React.useState((_): Close.t<Form.t<F.t, F.actions<()>>> => first)

    let _ = React.useMemo0( () => {
      dyn
      ->Dynamic.tap(x => setclose(_ => x))
      ->Dynamic.toPromise
      ->Promise.void
    })

    close->Close.pack
  }
}

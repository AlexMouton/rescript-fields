# Rescript Fields

Elaborate form validation for Rescript 

Fields is a module for managing the update and validation of complex input.
The singular Field module type describes the requirements for
creating, modifying and validating an input
Fields can be built that represent base level types values and inputs
Fields can be built that compose other Fields, (producing a tree of Fields)
allowing validation and change reduction at each level
one change or possibly having affect on multiple children

Each field is represented by a Field module that declares the storage, validation, and mutation of something.
Some fields are defined as Module Functions/Functors so they can be composed.  FieldArray for example.

The hope is that the basics will be nearly enough for small forms, but larger forms
and validations will be more easily tested in vitro.

## Installation

* Add `@nobleai/rescript-fields` to your project as you like
* Add `@nobleai/rescript-fields` to `bs-dev-dependencies`in bsconfig.json
* build `-with-deps`


## Login Form Example
```{rescript}
module FieldUsername = FieldString.Make({
  let validateImmediate = false
})

module FieldPassword = FieldString.Make({
  let validateImmediate = false
})

// Declare the structure of your desired output type
// This is outside of Generic to make accessors more easily available
@deriving(accessors)
type structure<'a, 'b> = {
  username: 'a,
  password: 'b,
}

// Give fields a map from your output type to a generic container (tuple)
module Generic = {
  type structure<'a, 'b> = structure<'a, 'b>

  let order = (username, password)
  let fromTuple = ((username, password)) => {username, password}
}

module Field = FieldProduct.Product2.Make(
  {
    let validateImmediate = false
  },
  Generic,
  FieldUsername,
  FieldPassword,
)

// Create a hook for running this field
module Form = UseField.Make(Field)

@react.component
let make = (~onSubmit) => {
  let field = Form.use(
    ~context={
      inner: {
        username: {validate: FieldString.length(~min=2, ())},
        password: {validate: FieldString.length(~min=2, ())},
      },
    },
    ~init={username: "", password: ""},
    (),
  )

  <form onSubmit={field.handleSubmit(onSubmit)}>
    {
      let {username, password} = field.field->Field.inner
      <div>
			<input
				value={username->FieldUsername.input}
				onChange={e => {
					let target = e->ReactEvent.Form.target
					target["value"]->FieldUsername.makeSet->Field.actions.username->field.reduce
				}}
			/>
			{ password
				->FieldUsername.printError
				->Option.map(React.string)
				->Option.or(React.null)
			}
			<input
				type_="password"
				value={password->FieldPassword.input}
				onChange={e => {
					let target = e->ReactEvent.Form.target
					target["value"]->FieldPassword.makeSet->Field.actions.password->field.reduce
				}}
				onBlur={(_) => #Validate->Field.actions.password->field.reduce}
			 />
				{ password
					->FieldPassword.printError
					->Option.map(React.string)
					->Option.or(React.null)
				}
      </div>
    }
		<button
			type_="submit"
			>{"Sign In"->React.string}
		</button>
  </form>
}
```


## TODO 
- debounced asyc validation  
- graphql async validation based on hook provided function  
- optimistic update chaging form twice?  
- write tests for specific product fields. range etc.  



# Mojo notes

## Dectorators

[`@always_inline`](https://docs.modular.com/mojo/manual/decorators/always-inline): decorator on any function to make the Mojo compiler "inline" the body of the function (copy it) directly into the body of the calling function.

[`@parameter`](https://docs.modular.com/mojo/manual/decorators/parameter): decorator on an if statement or on a nested function to run that code at compile time.

[`@register_passable`](https://docs.modular.com/mojo/manual/decorators/register-passable): decorator on a struct to tell Mojo that the type should be passed in machine registers (such as a CPU register; subject to the details of the underlying architecture).

[`@value`](https://docs.modular.com/mojo/manual/decorators/value): decorator on a struct to generate boilerplate lifecycle methods, including the member-wise __init__() constructor, __copyinit__() copy constructor, and __moveinit__() move constructor.

## Function arguments

* To define [positional-only arguments](https://docs.modular.com/mojo/manual/functions#positional-only-and-keyword-only-arguments), add a slash character (`/`) to the argument list. Any arguments before the `/` are positional-only: they can't be passed as keyword arguments.

* If the function doesn't accept variadic arguments, you can add a single star (*) to the argument list to separate the [keyword-only arguments](https://docs.modular.com/mojo/manual/functions#positional-only-and-keyword-only-arguments).

* [Variadic arguments](https://docs.modular.com/mojo/manual/functions#variadic-arguments) look like: `fn sum(*values: Int) -> Int:`
* Also, [any arguments declared after the variadic argument can only be specified by keyword.](https://docs.modular.com/mojo/manual/functions#variadic-arguments)

## Containers / arrays

[`StaticTuple`](https://docs.modular.com/mojo/stdlib/utils/static_tuple/StaticTuple): A statically sized tuple type which contains elements of homogeneous types. To use, `from utils import static_tuple`.

## Types

[`DType`](https://docs.modular.com/mojo/stdlib/builtin/dtype/DType) is a type that names other types, e.g., `var x: DType = DType.uint64`. Useful in generics.

## Generic trait members

This
```mojo
trait MyTrait[T: TypeClass]:
    ...
```
[is not allowed](https://docs.modular.com/mojo/manual/traits#using-traits). However, this
```mojo
trait MyTrait:
    fn passthrough[T: TypeClass](t: T) -> T:
        pass
    ...
```
is allowed. The trick is that a type fulfilling the trait must also be generic. Specialization only occurs at the point of invocation, not in the type definition. So
```mojo
struct MyStruct(MyTrait):
    fn passthrough(t: AType) -> AType:
        ...
```
is not allowed. But
```mojo
struct MyStruct(MyTrait):
    fn passthrough[T: TypeClass](t: T) -> T:
        return t

var s = MyStruct()
var t = SomeType()
var res: SomeType = s.passthrough(t)
```
is allowed. Specialization occurs in the last line.






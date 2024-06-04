# Mojo notes

## Dectorators

[`@always_inline`](https://docs.modular.com/mojo/manual/decorators/always-inline): decorator on any function to make the Mojo compiler "inline" the body of the function (copy it) directly into the body of the calling function.

[`@parameter`](https://docs.modular.com/mojo/manual/decorators/parameter): decorator on an if statement or on a nested function to run that code at compile time.

[`@register_passable`](https://docs.modular.com/mojo/manual/decorators/register-passable): decorator on a struct to tell Mojo that the type should be passed in machine registers (such as a CPU register; subject to the details of the underlying architecture).

[`@value`](https://docs.modular.com/mojo/manual/decorators/value): decorator on a struct to generate boilerplate lifecycle methods, including the member-wise __init__() constructor, __copyinit__() copy constructor, and __moveinit__() move constructor.




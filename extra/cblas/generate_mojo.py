from pycparser import c_parser, c_ast, parse_file

class MojoGenerator:
    def __init__(self):
        self.enums = []
        self.functions = []
        self.function_signatures = {}

    def visit_enum(self, node):
        # Convert enum name to camel-case and use it as a prefix, removing "Cblas"
        enum_name = self.to_camel_case(node.name.replace("CBLAS_", ""))

        for enumerator in node.values.enumerators:
            # Create the alias by combining the enum type name with the enum element name
            name = f"{enum_name}_{self.to_camel_case(enumerator.name.replace('Cblas', ''))}"
            value = enumerator.value.value if enumerator.value else None
            self.enums.append((name, value))

    def visit_funcdecl(self, node, func_name, signature):
        return_type = self.get_type(node.type)
        param_list = self.get_param_list(node.args)
        self.functions.append((func_name, return_type, param_list))
        self.function_signatures[func_name] = signature

    def get_type(self, node):
        if isinstance(node, c_ast.TypeDecl):
            if isinstance(node.type, c_ast.IdentifierType):
                base_type = node.type.names[0]
                if base_type == "int":
                    return "Int"
                elif base_type == "float":
                    return "F32"
                elif base_type == "double":
                    return "F64"
                elif base_type == "size_t":
                    return "Int"
                else:
                    return base_type
            elif isinstance(node.type, c_ast.Enum):
                return "Int"
            else:
                return "UnknownType"
        elif isinstance(node, c_ast.PtrDecl):
            return f"Pointer[{self.get_type(node.type)}]"
        elif isinstance(node, c_ast.FuncDecl):
            return f"fn ({self.get_param_list(node.args)})"
        else:
            return "Unknown"

    def get_param_list(self, param_list):
        params = []
        if param_list:
            for param in param_list.params:
                if isinstance(param, c_ast.EllipsisParam):
                    params.append("...") 
                else:
                    param_type = self.get_type(param.type)
                    params.append(param_type)
        return params

    def generate_mojo(self):
        mojo_code = []

        # Header with common structs and aliases
        header = """
from sys.ffi import DLHandle
from os.path.path import isfile
from os.env import getenv

alias F32 = Float32
alias F64 = Float64

@value
struct C32:
    var real: F32
    var imaginary: F32

    fn __init__(inout self, r: F32, i: F32):
        self.real = r
        self.imaginary = i

@value
struct C64:
    var real: F64
    var imaginary: F64

    fn __init__(inout self, r: F64, i: F64):
        self.real = r
        self.imaginary = i

alias PF32 = UnsafePointer[F32]
alias PF64 = UnsafePointer[F64]
alias PC32 = UnsafePointer[C32]
alias PC64 = UnsafePointer[C64]

struct CBLAS:
    """
        mojo_code.append(header.strip())

        # Add enum aliases
        for name, value in self.enums:
            mojo_code.append(f"    alias {name} = {value}")

        # Add function type aliases with comments
        variadic_functions = set()
        for func_name, return_type, param_list in self.functions:
            formatted_name = self.to_camel_case(func_name.replace("cblas_", "")) + "Type"
            param_list_str = ", ".join(param_list)

            # Get the original C function signature
            original_signature = self.function_signatures.get(func_name, f"{func_name}();")
            mojo_code.append(f"    # {original_signature.strip()}")

            # Replace types with custom aliases
            param_list_str = param_list_str.replace("Pointer[F32]", "PF32")
            param_list_str = param_list_str.replace("Pointer[F64]", "PF64")
            param_list_str = param_list_str.replace("Pointer[void]", self.determine_complex_pointer_type(func_name.lower()))
            return_type = return_type.replace("void", "None")

            # Comment out variadic functions
            if "..." in param_list_str:
                mojo_code.append(f"    # alias {formatted_name} = fn ({param_list_str}) -> {return_type}")
                variadic_functions.add(func_name.lower())
            else:
                mojo_code.append(f"    alias {formatted_name} = fn ({param_list_str}) -> {return_type}")

        # Add function pointer variables and initialization
        mojo_code.append("\n    var h: DLHandle")

        for func_name, _, _ in self.functions:
            formatted_name = self.to_camel_case(func_name.replace("cblas_", ""))
            if func_name.lower() in variadic_functions:
                mojo_code.append(f"    # var {formatted_name.lower()}: Self.{formatted_name}Type")
            else:
                mojo_code.append(f"    var {formatted_name.lower()}: Self.{formatted_name}Type")

        mojo_code.append("\n    fn __init__(inout self) raises:")
        mojo_code.append("        var path = getenv(\"MOJOSCI_CBLAS_DYNLIB_PATH\")")
        mojo_code.append("        self.__init__(path)")

        mojo_code.append("\n    fn __init__(inout self, path: String) raises:")
        mojo_code.append("        if not isfile(path):")
        mojo_code.append("            raise Error(\"Path does not point to a file\")")
        mojo_code.append("        self.h = DLHandle(path)")
        mojo_code.append("        if not self.h:")
        mojo_code.append("            raise Error(\"Cannot open dynamic library\")")

        for func_name, _, _ in self.functions:
            formatted_name = self.to_camel_case(func_name.replace("cblas_", ""))
            if func_name.lower() in variadic_functions:
                mojo_code.append(f"        # self.{formatted_name.lower()} = self.h.get_function[Self.{formatted_name}Type](\"{func_name}\")")
            else:
                mojo_code.append(f"        self.{formatted_name.lower()} = self.h.get_function[Self.{formatted_name}Type](\"{func_name}\")")

        return "\n".join(mojo_code)


    def to_camel_case(self, snake_str):
        components = snake_str.split('_')
        return ''.join(x.title() for x in components)

    def determine_complex_pointer_type(self, func_name):
        if func_name.startswith('cblas_'):
            func_name = func_name[6:]

        c_index = func_name.find('c')
        z_index = func_name.find('z')

        if c_index != -1 and (z_index == -1 or c_index < z_index):
            return "PC32"
        elif z_index != -1 and (c_index == -1 or z_index < c_index):
            return "PC64"
        else:
            return "Pointer[void]"

    def extract_function_signatures(self, header_file):
        with open(header_file, 'r') as file:
            lines = file.readlines()

        signature = ""
        inside_func = False
        inside_comment = False
        inside_extern_c_block = False

        for line in lines:
            stripped_line = line.strip()

            # Handle C-style comments
            if stripped_line.startswith("/*"):
                inside_comment = True
                continue
            if inside_comment:
                if "*/" in stripped_line:
                    inside_comment = False
                continue

            # Handle preprocessor directives and 'extern "C"' blocks
            if stripped_line.startswith("#") or 'extern "C"' in stripped_line:
                if '{' in stripped_line:
                    inside_extern_c_block = True
                continue

            if inside_extern_c_block:
                if '}' in stripped_line:
                    inside_extern_c_block = False
                continue

            if stripped_line.endswith(';'):
                if inside_func:
                    signature += " " + stripped_line
                    inside_func = False
                    func_name = self.get_function_name_from_signature(signature)
                    if func_name:
                        self.function_signatures[func_name] = signature
                    signature = ""
                else:
                    func_name = self.get_function_name_from_signature(stripped_line)
                    if func_name:
                        self.function_signatures[func_name] = stripped_line
            elif stripped_line:
                if not inside_func:
                    signature = stripped_line
                    inside_func = True
                else:
                    signature += " " + stripped_line

    def get_function_name_from_signature(self, signature):
        if '(' in signature:
            return signature.split('(')[0].split()[-1]
        return None

def main():
    header_file = 'cblas.h'  # Path to your cblas.h file
    fake_include_dir = 'fake_headers'  # Path to your fake header directory
    generator = MojoGenerator()

    generator.extract_function_signatures(header_file)

    ast = parse_file(header_file, use_cpp=True, 
                     cpp_args=[f'-I{fake_include_dir}', '-D__attribute__(x)='])

    for node in ast.ext:
        if isinstance(node, c_ast.Decl):
            if isinstance(node.type, c_ast.Enum):
                generator.visit_enum(node.type)
            elif isinstance(node.type, c_ast.FuncDecl):
                signature = generator.function_signatures.get(node.name, "")
                generator.visit_funcdecl(node.type, node.name, signature)

    mojo_code = generator.generate_mojo()
    print(mojo_code)

if __name__ == "__main__":
    main()

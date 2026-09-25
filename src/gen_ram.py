import numpy as np

def gen_sin(n: int):
    return (np.sin(np.linspace(0, 2*np.pi, n+1)[:-1]) + 1)/2

@np.vectorize
def fmt_float_int(x, nbits=14):
    return str(int(np.rint(x*(2**nbits-1))))

def gen_vhdl(n, nbits=14, name='RAM', type_name='ram_t', per_line=16):
    vals = fmt_float_int(gen_sin(n), nbits)
    lines = [', '.join(vals[i:i+per_line]) for i in range(0, n, per_line)]
    r = f"type {type_name} is array (0 to {n-1}) of integer range 0 to {2**nbits-1};\n"
    r += f"signal {name}: {type_name} :=(\n\t" + ",\n\t".join(lines) + ");\n"
    return r

if __name__ == '__main__':
    print(gen_vhdl(1024))

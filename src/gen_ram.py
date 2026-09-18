import numpy as np

def gen_sin(n: int):
    return (np.sin(np.linspace(0, 2*np.pi, n+1)[:-1]) + 1)/2

@np.vectorize
def fmt_float_hex(x, nbits=14):
    x = int(np.rint(x*(2**nbits-1)))
    return hex(x)[2:].rjust(int(np.ceil(nbits/4)), '0')

def gen_vhdl(n, nbits=14, name='RAM', type_name='ram_t'):
    r = f"type {type_name} is array (0 to {n-1}) of  std_logic_vector ({nbits-1} downto 0);\n"
    r += f"signal {name}: {type_name} :=({nbits}x\"{f'",{nbits}x"'.join(fmt_float_hex(gen_sin(n), nbits))}\");\n"
    return r

if __name__ == '__main__':
    print(gen_vhdl(1024))

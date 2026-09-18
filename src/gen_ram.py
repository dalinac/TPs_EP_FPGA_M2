import numpy as np

def gen_sin(n: int):
    return np.sin(np.linspace(0, 2*np.pi, n+1)[:-1])

@np.vectorize
def fmt_float_hex(x, nbits=14):
    x = int(np.rint(x*2**nbits))
    if x < 0:
        x = 2**nbits + x
    return hex(x)[2:]

def gen_vhdl(n, nbits=14, name='RAM', type_name='RAM_ARRAY'):
    r = f"type {type_name} is array (0 to {n}) of std_logic_vector ({nbits} downto 0);\n"
    r += f"signal {name}: {type_name} :=(x\" {'",x"'.join(fmt_float_hex(gen_sin(n), nbits))}\");\n"
    return r

if __name__ == '__main__':
    print(gen_vhdl(1024))

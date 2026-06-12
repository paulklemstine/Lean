from typing import NamedTuple

class Triple(NamedTuple):
    a: int; b: int; c: int

def left(t): a,b,c=t; return Triple(a-2*b+2*c,2*a-b+2*c,2*a-2*b+3*c)
def mid(t): a,b,c=t; return Triple(a+2*b+2*c,2*a+b+2*c,2*a+2*b+3*c)
def right(t): a,b,c=t; return Triple(-a+2*b+2*c,-2*a+b+2*c,-2*a+2*b+3*c)

root = Triple(3, 4, 5)
paths = {
    'All Left (L^n)': [left]*10,
    'All Mid (M^n)': [mid]*10,
    'All Right (R^n)': [right]*10,
    'Alternating L-R': [left,right]*5,
    'Alternating L-M-R': [left,mid,right]*3+[left],
}

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(10, 6))
    for label, steps in paths.items():
        t = root
        cs = [t.c]
        for fn in steps:
            t = fn(t)
            cs.append(t.c)
        ax.plot(range(len(cs)), cs, 'o-', label=label, markersize=4)
    ax.set_xlabel('Depth in Berggren Tree')
    ax.set_ylabel('Hypotenuse c')
    ax.set_title('Hypotenuse Growth Along Different Berggren Paths')
    ax.set_yscale('log')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('hypotenuse_growth.png', dpi=150)
    print('Saved hypotenuse_growth.png')
except ImportError:
    print('matplotlib not available; printing values.')
    for label, steps in paths.items():
        t = root
        cs = [t.c]
        for fn in steps:
            t = fn(t)
            cs.append(t.c)
        print(f'{label}: {cs}')
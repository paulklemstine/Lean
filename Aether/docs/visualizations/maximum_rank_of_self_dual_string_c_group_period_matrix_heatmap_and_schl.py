import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple

Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def order_of(p: Perm) -> int:
    n = len(p); e = tuple(range(n)); pw = p; k = 1
    while pw != e:
        pw = compose(pw, p); k += 1
    return k

def transposition(n: int, a: int, b: int) -> Perm:
    p = list(range(n)); p[a], p[b] = p[b], p[a]; return tuple(p)

def double(sigma: Perm) -> Perm:
    k = len(sigma); out = list(range(2 * k + 1))
    for i in range(k):
        out[i] = sigma[i]; out[k + i] = k + sigma[i]
    return tuple(out)

def doubled_simplex_generators(m: int) -> List[Perm]:
    k = 2 * m + 1
    return [double(transposition(k, i, i + 1)) for i in range(2 * m)]

def main(m: int = 3) -> None:
    gens = doubled_simplex_generators(m)
    r = len(gens)
    P = np.array([[order_of(compose(gens[i], gens[j]))
                   for j in range(r)] for i in range(r)])
    schlafli = [int(P[k, k + 1]) for k in range(r - 1)]
    fig, ax = plt.subplots(1, 2, figsize=(11, 4.5))
    im = ax[0].imshow(P, cmap='viridis')
    ax[0].set_title(f'Period matrix of A_{4*m+3} rank-{r} rep')
    ax[0].set_xlabel('j'); ax[0].set_ylabel('i')
    fig.colorbar(im, ax=ax[0], fraction=0.046)
    ax[1].plot(range(len(schlafli)), schlafli, 'o-', label='Schlaefli')
    ax[1].plot(range(len(schlafli)), schlafli[::-1], 'x--',
               label='reversed')
    ax[1].set_title('Schlaefli symbol is a palindrome')
    ax[1].set_xlabel('edge index k'); ax[1].set_ylabel('p_k')
    ax[1].legend()
    fig.tight_layout()
    fig.savefig('selfdual_period_schlafli.png', dpi=150)
    print('saved selfdual_period_schlafli.png')

if __name__ == '__main__':
    main()

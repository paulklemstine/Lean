from typing import List

def visualize_chain_criticality(N: int = 8, out_path: str = 'chain_criticality.png'
                                ) -> None:
    grid: List[List[int]] = [[1 if n <= m else 0 for n in range(N + 1)]
                             for m in range(N)]
    try:
        import matplotlib.pyplot as plt
        plt.imshow(grid, cmap='RdYlGn', aspect='auto', origin='lower')
        plt.xlabel('target n'); plt.ylabel('deleted axiom m -> m+1')
        plt.title('Chain criticality: green = 0 still derives n')
        plt.colorbar(label='derivable (1) / blocked (0)')
        plt.savefig(out_path, dpi=140, bbox_inches='tight'); plt.close()
        print(f'wrote {out_path}')
    except Exception:
        for m, row in enumerate(grid):
            print(f'delete {m}->{m+1}: ' + ''.join('#' if c else '.' for c in row))

if __name__ == '__main__':
    visualize_chain_criticality()

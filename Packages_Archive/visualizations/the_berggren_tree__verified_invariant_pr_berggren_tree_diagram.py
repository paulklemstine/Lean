from typing import NamedTuple

class Triple(NamedTuple):
    a: int; b: int; c: int

def left(t): a,b,c=t; return Triple(a-2*b+2*c,2*a-b+2*c,2*a-2*b+3*c)
def mid(t): a,b,c=t; return Triple(a+2*b+2*c,2*a+b+2*c,2*a+2*b+3*c)
def right(t): a,b,c=t; return Triple(-a+2*b+2*c,-2*a+b+2*c,-2*a+2*b+3*c)

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches

    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    ax.set_xlim(-1, 28)
    ax.set_ylim(-1, 8)
    ax.axis('off')
    ax.set_title('Berggren Ternary Tree of Primitive Pythagorean Triples', fontsize=16, fontweight='bold')

    def draw_node(ax, x, y, triple, fontsize=9):
        label = f'({triple.a},{triple.b},{triple.c})'
        ax.text(x, y, label, ha='center', va='center', fontsize=fontsize,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', edgecolor='navy', alpha=0.9))

    def draw_edge(ax, x1, y1, x2, y2, label):
        ax.annotate('', xy=(x2, y2+0.35), xytext=(x1, y1-0.35),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.2))
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx-0.3, my, label, fontsize=8, color='red', fontweight='bold')

    root = Triple(3, 4, 5)
    # Level 0
    draw_node(ax, 13.5, 7, root, fontsize=11)
    # Level 1
    children1 = [left(root), mid(root), right(root)]
    x1_positions = [4, 13.5, 23]
    labels1 = ['L', 'M', 'R']
    for i, (child, x) in enumerate(zip(children1, x1_positions)):
        draw_node(ax, x, 4.5, child)
        draw_edge(ax, 13.5, 7, x, 4.5, labels1[i])
    # Level 2
    for i, (parent, px) in enumerate(zip(children1, x1_positions)):
        children2 = [left(parent), mid(parent), right(parent)]
        offsets = [-2.5, 0, 2.5]
        for j, (child, off) in enumerate(zip(children2, offsets)):
            cx = px + off
            draw_node(ax, cx, 1.5, child, fontsize=7)
            draw_edge(ax, px, 4.5, cx, 1.5, labels1[j])

    plt.tight_layout()
    plt.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    print('Saved berggren_tree.png')
except ImportError:
    print('matplotlib not available; printing tree textually.')
    root = Triple(3,4,5)
    print(f'Root: {root}')
    for name, fn in [('L',left),('M',mid),('R',right)]:
        child = fn(root)
        print(f'  {name}: {child}')
        for name2, fn2 in [('L',left),('M',mid),('R',right)]:
            print(f'    {name}{name2}: {fn2(child)}')
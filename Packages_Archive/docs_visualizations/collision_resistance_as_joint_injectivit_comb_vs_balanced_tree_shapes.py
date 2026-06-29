import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import Union

@dataclass(frozen=True)
class Leaf:
    value: int

@dataclass(frozen=True)
class Node:
    left: 'BTree'
    right: 'BTree'

BTree = Union[Leaf, Node]

def nat_pair(a, b):
    return b*b+a if a < b else a*a+a+b

def tree_hash(t):
    if isinstance(t, Leaf):
        return t.value
    return nat_pair(tree_hash(t.left), tree_hash(t.right))

def layout(t, x, y, dx, pos):
    if isinstance(t, Leaf):
        pos[id(t)] = (x, y, str(t.value), True)
        return x
    lx = layout(t.left, x, y-1, dx/2, pos)
    rx = layout(t.right, lx+dx, y-1, dx/2, pos)
    mx = (lx + rx) / 2
    pos[id(t)] = (mx, y, str(tree_hash(t)), False)
    return rx

def draw(ax, t, title):
    pos = {}
    layout(t, 0, 0, 4, pos)
    def edges(n):
        if isinstance(n, Node):
            for c in (n.left, n.right):
                x0,y0,_,_ = pos[id(n)]; x1,y1,_,_ = pos[id(c)]
                ax.plot([x0,x1],[y0,y1],'k-',zorder=1); edges(c)
    edges(t)
    for (x,y,lbl,leaf) in pos.values():
        ax.scatter([x],[y],s=600,c=('#cde' if leaf else '#fda'),zorder=2,edgecolors='k')
        ax.text(x,y,lbl,ha='center',va='center',fontsize=8,zorder=3)
    ax.set_title(title); ax.axis('off')

leaves = [1,2,3,4]
comb = Leaf(leaves[0])
for v in leaves[1:]: comb = Node(comb, Leaf(v))
bal = Node(Node(Leaf(1),Leaf(2)), Node(Leaf(3),Leaf(4)))
rcomb = Leaf(leaves[-1])
for v in reversed(leaves[:-1]): rcomb = Node(Leaf(v), rcomb)
fig, axs = plt.subplots(1,3,figsize=(15,4))
draw(axs[0], comb, 'Left comb = Merkle-Damgard chain')
draw(axs[1], bal,  'Balanced tree')
draw(axs[2], rcomb,'Right comb')
plt.tight_layout(); plt.savefig('tree_shapes.png', dpi=120)
print('wrote tree_shapes.png')

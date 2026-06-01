#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def newton_verts(s1, s2): return [(0,0),(1,s1),(2,s1+s2)]
def hodge_verts(h1, h2): return [(0,0),(1,h1),(2,h1+h2)]

def plot_pair(ax, s1, s2, h1, h2, title):
    nx,ny = zip(*newton_verts(s1,s2))
    hx,hy = zip(*hodge_verts(h1,h2))
    ax.fill_between([0,1,2],[ny[0],ny[1],ny[2]],[hy[0],hy[1],hy[2]],alpha=0.15,color='blue')
    ax.plot(nx,ny,'b-o',lw=2,ms=8,label='Newton')
    ax.plot(hx,hy,'r--s',lw=2,ms=8,label='Hodge')
    ax.set_title(title,fontweight='bold'); ax.legend(); ax.grid(alpha=0.3)

fig,axes = plt.subplots(1,3,figsize=(14,4))
plot_pair(axes[0],0,1,0,1,'Weight 2: Ordinary')
plot_pair(axes[1],0.5,0.5,0,1,'Weight 2: Supersingular')
plot_pair(axes[2],3,8,0,11,'Weight 12: Slopes (3,8)')
plt.tight_layout(); plt.savefig('newton_hodge.png',dpi=150); print('Saved')
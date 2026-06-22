import matplotlib.pyplot as plt
from typing import List

def mat_vec(A, v):
    return [min(A[i][j] + v[j] for j in range(len(v))) for i in range(len(A))]

v = [0, 3, 1]
A = [[(v[i] + 1) - v[j] for j in range(3)] for i in range(3)]
ks = list(range(0, 21))
traj = [[0]*len(v) for _ in ks]
w = list(v)
for t, k in enumerate(ks):
    traj[t] = [int(x) for x in w]
    w = mat_vec(A, w)
for i in range(len(v)):
    plt.plot(ks, [traj[t][i] for t in range(len(ks))], marker='o',
             label=f'coordinate {i} (start {v[i]})')
plt.xlabel('iteration count k (the secret exponent)')
plt.ylabel('F^[k](v) coordinate value')
plt.title('Each coordinate grows as k + v[i]: the secret slope is 1')
plt.legend(); plt.grid(True); plt.tight_layout()
plt.savefig('eigenline_leak.png', dpi=150)
print('saved eigenline_leak.png')

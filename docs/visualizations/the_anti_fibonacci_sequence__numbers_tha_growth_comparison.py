#!/usr/bin/env python3
import matplotlib.pyplot as plt
import numpy as np

def anti_fib(n):
    return n * (n - 1) // 2 + 1

def fib_seq(m):
    s = [0, 1]
    for _ in range(m): s.append(s[-1] + s[-2])
    return s

N = 30
ns = list(range(N+1))
af = [anti_fib(n) for n in ns]
fibs = fib_seq(N+1)[:N+1]
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14,6))
ax1.plot(ns, af, 'b-o', ms=4, lw=2, label='Anti-Fibonacci')
ax1.plot(ns, fibs, 'r-s', ms=4, lw=2, label='Fibonacci')
ax1.set_xlabel('n'); ax1.set_ylabel('Value'); ax1.legend(); ax1.grid(alpha=0.3)
ax1.set_title('Linear Scale')
ax2.semilogy([n for n,v in zip(ns,af) if v>0], [v for v in af if v>0], 'b-o', ms=4, lw=2, label='Anti-Fib ~ n²/2')
ax2.semilogy([n for n,v in zip(ns,fibs) if v>0], [v for v in fibs if v>0], 'r-s', ms=4, lw=2, label='Fib ~ φⁿ')
ax2.set_xlabel('n'); ax2.set_ylabel('Value (log)'); ax2.legend(); ax2.grid(alpha=0.3)
ax2.set_title('Log Scale')
fig.suptitle('Anti-Fibonacci vs Fibonacci Growth', fontsize=16, fontweight='bold')
plt.tight_layout(); plt.savefig('antifib_growth.png', dpi=150); plt.close()
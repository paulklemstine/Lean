import matplotlib.pyplot as plt
import numpy as np

def horn_step(state):
    result = list(state)
    result[0] = True
    for i in range(1, len(state)):
        result[i] = result[i] or state[i-1]
    return tuple(result)

N = 8
bot = tuple([False]*N)
chain = [bot]
x = bot
for _ in range(N+2):
    x = horn_step(x)
    chain.append(x)

data = np.array([[int(v) for v in step] for step in chain])
fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(data.T, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax.set_xlabel('Iteration Step', fontsize=12)
ax.set_ylabel('Proposition Index', fontsize=12)
ax.set_title('Kleene Chain Convergence: Horn Clause System', fontsize=14)
ax.set_yticks(range(N))
ax.set_yticklabels([f'P{i}' for i in range(N)])
plt.colorbar(im, label='Truth Value')
plt.tight_layout()
plt.savefig('kleene_convergence.png', dpi=150)
plt.show()

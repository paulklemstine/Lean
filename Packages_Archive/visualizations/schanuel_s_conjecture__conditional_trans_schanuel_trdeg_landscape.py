import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

examples = [
    {"label": "z=(1)", "n": 1, "alg_z": 1, "trans_z": 0, "alg_exp": 0, "trans_exp": 1},
    {"label": "z=(log 2)", "n": 1, "alg_z": 0, "trans_z": 1, "alg_exp": 1, "trans_exp": 0},
    {"label": "z=(1,√2)", "n": 2, "alg_z": 2, "trans_z": 0, "alg_exp": 0, "trans_exp": 2},
    {"label": "z=(1,iπ)", "n": 2, "alg_z": 1, "trans_z": 1, "alg_exp": 1, "trans_exp": 1},
]

fig, ax = plt.subplots(1, 1, figsize=(10, 6))
x = np.arange(len(examples))
width = 0.2

ax.bar(x - 1.5*width, [e["alg_z"] for e in examples], width, label="Algebraic z_i", color="#4e79a7")
ax.bar(x - 0.5*width, [e["trans_z"] for e in examples], width, label="Transcendental z_i", color="#59a14f")
ax.bar(x + 0.5*width, [e["alg_exp"] for e in examples], width, label="Algebraic exp(z_i)", color="#f28e2b")
ax.bar(x + 1.5*width, [e["trans_exp"] for e in examples], width, label="Transcendental exp(z_i)", color="#e15759")

ax.axhline(y=0, color='black', linewidth=0.5)
for i, e in enumerate(examples):
    ax.plot([i-2*width, i+2*width], [e["n"], e["n"]], 'k--', linewidth=2)
    ax.text(i+2.2*width, e["n"], f'n={e["n"]}', va='center', fontsize=10)

ax.set_xlabel("Example", fontsize=12)
ax.set_ylabel("Count", fontsize=12)
ax.set_title("Schanuel's Conjecture: Transcendence Degree Landscape", fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels([e["label"] for e in examples])
ax.legend(loc="upper left")
ax.set_ylim(0, 3.5)
plt.tight_layout()
plt.savefig("schanuel_trdeg_landscape.png", dpi=150)
print("Saved schanuel_trdeg_landscape.png")

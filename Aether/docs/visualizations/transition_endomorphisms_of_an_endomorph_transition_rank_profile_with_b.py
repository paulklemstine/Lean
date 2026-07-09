"""Visualize the transition-rank profile of an endomorphism stream and its
eventual stabilization.  Requires matplotlib + numpy."""
import numpy as np
import matplotlib.pyplot as plt


def stream_matrices():
    # Three rank-dropping maps on R^4, then identity (the COLLAPSING stream).
    return [
        np.diag([1, 1, 1, 0]).astype(float),
        np.diag([1, 1, 0, 0]).astype(float),
        np.array([[1, 1, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], float),
    ]


def trans_endo(mats, j, d=4):
    acc = np.eye(d)
    for step in range(j):
        m = mats[step] if step < len(mats) else np.eye(d)
        acc = m @ acc
    return acc


def main():
    mats = stream_matrices()
    d = 4
    ms = list(range(8))
    profile = [int(round(np.linalg.matrix_rank(trans_endo(mats, m, d)))) for m in ms]
    stable = profile[-1]
    N = next(m for m in ms if all(v == stable for v in profile[m:]))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(ms, profile, where="post", linewidth=2.5, color="#2c3e50",
            label="rank(transEndo f 0 m)")
    ax.axhline(d, ls="--", color="#7f8c8d", label=f"finrank K V = {d}")
    ax.axhline(stable, ls=":", color="#e74c3c", label=f"stable rank = {stable}")
    ax.axvline(N, ls=":", color="#27ae60", label=f"stabilization N = {N}")
    ax.scatter(ms, profile, color="#2c3e50", zorder=5)
    ax.set_xlabel("window length m")
    ax.set_ylabel("transition rank")
    ax.set_title("Transition-rank profile: antitone, bounded, eventually constant")
    ax.set_ylim(-0.3, d + 0.5)
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("transition_rank_profile.png", dpi=150)
    print("saved transition_rank_profile.png")


if __name__ == "__main__":
    main()

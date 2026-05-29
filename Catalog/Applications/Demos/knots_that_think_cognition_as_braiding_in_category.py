"""
applications.py — Real-World Applications of Cognitive Braid Theory

Demonstrates how braid-theoretic invariants can be applied to:
1. EEG signal analysis (brain region interleaving)
2. Task complexity scoring
3. Creative process evaluation
"""

from typing import List, Tuple
import math
import random

random.seed(42)


# ─── Inline Core Classes ─────────────────────────────────────────────────

class BraidGenerator:
    def __init__(self, index: int, sign: int = 1):
        self.index = index
        self.sign = sign
    def inverse(self):
        return BraidGenerator(self.index, -self.sign)
    def __repr__(self):
        s = "" if self.sign == 1 else "⁻¹"
        return f"σ{s}_{self.index}"

class BraidWord:
    def __init__(self, n: int, gens: List[BraidGenerator] = None):
        self.n = n
        self.gens = gens or []

    @property
    def writhe(self): return sum(g.sign for g in self.gens)

    @property
    def crossing_number(self): return len(self.gens)

    @property
    def info_content(self): return abs(self.writhe)

    def cognitive_level(self):
        k = self.crossing_number
        if k == 0: return "trivial"
        elif k <= 2: return "simple"
        elif k <= 5: return "moderate"
        else: return "complex"


# ─── Application 1: EEG-inspired Braid Construction ──────────────────────

def eeg_to_braid(channels: List[str], activation_sequence: List[Tuple[str, str]]) -> BraidWord:
    """
    Convert an EEG activation sequence to a cognitive braid.

    Each pair (ch_i, ch_j) represents channel ch_i's signal crossing
    above channel ch_j's signal in time, creating a braid crossing.

    Args:
        channels: List of EEG channel names.
        activation_sequence: List of (dominant, subordinate) channel pairs.

    Returns:
        A BraidWord representing the neural firing pattern.

    Example:
        channels = ["frontal", "parietal", "temporal", "occipital"]
        sequence = [("frontal", "parietal"), ("temporal", "parietal"), ...]
    """
    n = len(channels)
    ch_idx = {ch: i for i, ch in enumerate(channels)}

    generators = []
    for dominant, subordinate in activation_sequence:
        i = ch_idx[dominant]
        j = ch_idx[subordinate]
        if abs(i - j) == 1:
            idx = min(i, j)
            sign = 1 if i < j else -1
            generators.append(BraidGenerator(idx, sign))

    return BraidWord(n, generators)


def demo_eeg_application():
    """Demonstrate EEG signal analysis as braid topology."""
    print("=" * 60)
    print("APPLICATION 1: EEG Signal Analysis as Braid Topology")
    print("=" * 60)

    channels = ["frontal", "parietal", "temporal", "occipital"]

    # Scenario 1: Linear sequential activation (trivial braid)
    print("\n  Scenario: Resting state (sequential activation)")
    rest_braid = BraidWord(4)  # No crossings
    print(f"    Braid: identity")
    print(f"    Writhe: {rest_braid.writhe}")
    print(f"    Level: {rest_braid.cognitive_level()}")

    # Scenario 2: Creative insight — multiple regions cross-activate
    print("\n  Scenario: Creative insight (cross-region activation)")
    creative_seq = [
        ("frontal", "parietal"),   # frontal dominates parietal
        ("parietal", "temporal"),  # parietal dominates temporal
        ("frontal", "parietal"),   # frontal re-dominates
        ("parietal", "temporal"),  # back-and-forth
        ("temporal", "occipital"), # spreads to visual cortex
    ]
    creative_braid = eeg_to_braid(channels, creative_seq)
    print(f"    Crossings: {creative_braid.crossing_number}")
    print(f"    Writhe: {creative_braid.writhe}")
    print(f"    Info content: {creative_braid.info_content}")
    print(f"    Level: {creative_braid.cognitive_level()}")

    # Scenario 3: Confused state — contradictory activations
    print("\n  Scenario: Confusion (contradictory activations)")
    confused_seq = [
        ("frontal", "parietal"),
        ("parietal", "frontal"),    # reversal!
        ("frontal", "parietal"),
        ("parietal", "frontal"),    # another reversal
    ]
    confused_braid = eeg_to_braid(channels, confused_seq)
    print(f"    Crossings: {confused_braid.crossing_number}")
    print(f"    Writhe: {confused_braid.writhe}")
    print(f"    Info content: {confused_braid.info_content}")
    print(f"    Level: {confused_braid.cognitive_level()}")
    print(f"    Note: High crossings but zero writhe — cancellation = confusion!")
    print()


# ─── Application 2: Task Complexity Scoring ──────────────────────────────

def score_task_complexity(subtask_regions: List[List[int]], n_regions: int) -> dict:
    """
    Score the cognitive complexity of a task based on which brain regions
    each subtask activates and how they interleave.

    Args:
        subtask_regions: For each subtask, list of region indices it activates.
        n_regions: Total number of brain regions.

    Returns:
        Dict with complexity score and cognitive level.
    """
    generators = []
    for i in range(len(subtask_regions) - 1):
        curr = set(subtask_regions[i])
        next_task = set(subtask_regions[i + 1])
        # Crossings occur when different regions swap dominance
        for r in curr:
            for s in next_task:
                if abs(r - s) == 1 and r not in next_task:
                    generators.append(BraidGenerator(min(r, s), 1 if r < s else -1))

    braid = BraidWord(n_regions, generators)
    return {
        "crossings": braid.crossing_number,
        "writhe": braid.writhe,
        "info_content": braid.info_content,
        "level": braid.cognitive_level(),
        "info_le_complexity": braid.info_content <= braid.crossing_number,
    }


def demo_task_scoring():
    """Demonstrate task complexity scoring."""
    print("=" * 60)
    print("APPLICATION 2: Task Complexity Scoring")
    print("=" * 60)

    n_regions = 5

    tasks = {
        "Reading text aloud": [[0, 1], [1, 2], [2, 3], [3, 4]],
        "Mental arithmetic": [[0, 1], [2, 3], [0, 1], [2, 3], [0, 1]],
        "Creative writing": [[0, 1], [3, 4], [1, 2], [0, 3], [2, 4], [1, 3], [0, 2]],
        "Mindless scrolling": [[0], [0], [0], [0]],
    }

    for task_name, regions in tasks.items():
        result = score_task_complexity(regions, n_regions)
        print(f"\n  Task: {task_name}")
        print(f"    Crossings: {result['crossings']}")
        print(f"    Writhe: {result['writhe']}")
        print(f"    Info content: {result['info_content']}")
        print(f"    Level: {result['level']}")
        print(f"    Info ≤ Complexity: {result['info_le_complexity']} (theorem)")
    print()


# ─── Application 3: Creative Process Evaluation ──────────────────────────

def evaluate_creative_process(stages: List[str]) -> dict:
    """
    Evaluate a creative process by modeling each stage transition as a
    braid crossing between cognitive modes.

    Cognitive modes: analytical(0), intuitive(1), critical(2), imaginative(3)
    """
    mode_map = {"analytical": 0, "intuitive": 1, "critical": 2, "imaginative": 3}
    n = 4  # four cognitive modes

    generators = []
    for i in range(len(stages) - 1):
        a = mode_map.get(stages[i], 0)
        b = mode_map.get(stages[i + 1], 0)
        if a != b and abs(a - b) == 1:
            idx = min(a, b)
            sign = 1 if a < b else -1
            generators.append(BraidGenerator(idx, sign))

    braid = BraidWord(n, generators)

    # Quantum dimension proxy
    w = braid.writhe
    qdim = math.log(abs(w) + 1) if w != 0 else 0.0

    return {
        "stages": " → ".join(stages),
        "crossings": braid.crossing_number,
        "writhe": braid.writhe,
        "level": braid.cognitive_level(),
        "quantum_dimension": round(qdim, 3),
        "is_creative": braid.crossing_number >= 3 and braid.info_content > 0,
    }


def demo_creative_evaluation():
    """Demonstrate creative process evaluation."""
    print("=" * 60)
    print("APPLICATION 3: Creative Process Evaluation")
    print("=" * 60)

    processes = [
        ("Linear analysis", ["analytical", "analytical", "analytical"]),
        ("Aha! moment", ["analytical", "intuitive", "critical", "intuitive", "imaginative"]),
        ("Brainstorm", ["imaginative", "critical", "imaginative", "intuitive",
                        "analytical", "intuitive", "imaginative"]),
        ("Rumination", ["analytical", "intuitive", "analytical", "intuitive",
                        "analytical", "intuitive"]),
    ]

    for name, stages in processes:
        result = evaluate_creative_process(stages)
        print(f"\n  Process: {name}")
        print(f"    Stages: {result['stages']}")
        print(f"    Crossings: {result['crossings']}")
        print(f"    Writhe: {result['writhe']}")
        print(f"    Level: {result['level']}")
        print(f"    Quantum Dim: {result['quantum_dimension']}")
        print(f"    Creative: {'Yes ✓' if result['is_creative'] else 'No'}")
    print()


if __name__ == "__main__":
    print("\n🧠 COGNITIVE BRAIDS: Real-World Applications\n")
    demo_eeg_application()
    demo_task_scoring()
    demo_creative_evaluation()
    print("All applications demonstrated successfully! ✓")


"""
demo.py — Cognitive Braids: Demonstrating Cognition as Braiding

This module demonstrates the core theorems from our formalization of
cognitive processes as elements of braid groups. We compute writhe,
crossing numbers, and information content for various "thought braids."
"""

from typing import List, Tuple

# ─── Braid Generator Representation ───────────────────────────────────────

class BraidGen:
    """A generator of the braid group B_n: σ_i (positive) or σ_i⁻¹ (negative)."""
    def __init__(self, index: int, positive: bool = True):
        self.index = index
        self.positive = positive

    @property
    def sign(self) -> int:
        return 1 if self.positive else -1

    def inv(self) -> 'BraidGen':
        return BraidGen(self.index, not self.positive)

    def __repr__(self):
        s = "σ" if self.positive else "σ⁻¹"
        return f"{s}_{self.index}"

# ─── Braid Word ───────────────────────────────────────────────────────────

class BraidWord:
    """A braid word: a sequence of generators representing a cognitive process."""
    def __init__(self, n: int, generators: List[BraidGen] = None):
        self.n = n  # number of strands (brain regions)
        self.generators = generators or []

    def comp(self, other: 'BraidWord') -> 'BraidWord':
        """Compose two braid words (concatenation)."""
        assert self.n == other.n
        return BraidWord(self.n, self.generators + other.generators)

    def inv(self) -> 'BraidWord':
        """Inverse of the braid word."""
        return BraidWord(self.n, [g.inv() for g in reversed(self.generators)])

    @property
    def writhe(self) -> int:
        """The writhe: sum of signs of all crossings."""
        return sum(g.sign for g in self.generators)

    @property
    def crossing_number(self) -> int:
        """Number of crossings."""
        return len(self.generators)

    @property
    def info_content(self) -> int:
        """Information content: |writhe|."""
        return abs(self.writhe)

    def cog_level(self) -> str:
        """Cognitive complexity level."""
        k = self.crossing_number
        if k == 0: return "trivial"
        elif k <= 2: return "simple"
        elif k <= 5: return "moderate"
        else: return "complex"

    def __repr__(self):
        if not self.generators:
            return f"B_{self.n}[id]"
        return f"B_{self.n}[{'·'.join(str(g) for g in self.generators)}]"


# ─── Canonical Braids ─────────────────────────────────────────────────────

def identity_braid(n: int) -> BraidWord:
    """The identity (trivial) braid — linear thought."""
    return BraidWord(n, [])

def trefoil_braid(n: int = 2) -> BraidWord:
    """The trefoil braid σ₁³ — creative insight."""
    return BraidWord(n, [BraidGen(0), BraidGen(0), BraidGen(0)])

def figure_eight_braid(n: int = 3) -> BraidWord:
    """The figure-eight knot braid σ₁σ₂⁻¹σ₁σ₂⁻¹ — confused thinking."""
    return BraidWord(n, [
        BraidGen(0, True), BraidGen(1, False),
        BraidGen(0, True), BraidGen(1, False)
    ])

def hopf_braid(n: int = 2) -> BraidWord:
    """The Hopf link braid σ₁² — simple association."""
    return BraidWord(n, [BraidGen(0), BraidGen(0)])


# ─── Demonstrations ──────────────────────────────────────────────────────

def demo_writhe_additivity():
    """Demonstrate Theorem: writhe(w₁·w₂) = writhe(w₁) + writhe(w₂)"""
    print("=" * 60)
    print("THEOREM: Writhe is additive under composition")
    print("=" * 60)

    w1 = trefoil_braid(3)
    w2 = figure_eight_braid(3)
    composed = w1.comp(w2)

    print(f"  w₁ = {w1}")
    print(f"  writhe(w₁) = {w1.writhe}")
    print(f"  w₂ = {w2}")
    print(f"  writhe(w₂) = {w2.writhe}")
    print(f"  w₁·w₂ = {composed}")
    print(f"  writhe(w₁·w₂) = {composed.writhe}")
    print(f"  writhe(w₁) + writhe(w₂) = {w1.writhe + w2.writhe}")
    assert composed.writhe == w1.writhe + w2.writhe
    print("  ✓ Verified: writhe(w₁·w₂) = writhe(w₁) + writhe(w₂)")
    print()


def demo_writhe_inverse():
    """Demonstrate Theorem: writhe(w⁻¹) = -writhe(w)"""
    print("=" * 60)
    print("THEOREM: Writhe of inverse negates")
    print("=" * 60)

    w = trefoil_braid(3)
    w_inv = w.inv()

    print(f"  w = {w}")
    print(f"  writhe(w) = {w.writhe}")
    print(f"  w⁻¹ = {w_inv}")
    print(f"  writhe(w⁻¹) = {w_inv.writhe}")
    assert w_inv.writhe == -w.writhe
    print("  ✓ Verified: writhe(w⁻¹) = -writhe(w)")

    comp = w.comp(w_inv)
    print(f"  w·w⁻¹ = {comp}")
    print(f"  writhe(w·w⁻¹) = {comp.writhe}")
    assert comp.writhe == 0
    print("  ✓ Verified: writhe(w·w⁻¹) = 0")
    print()


def demo_info_bound():
    """Demonstrate Theorem: |writhe| ≤ crossing_number"""
    print("=" * 60)
    print("THEOREM: Information content ≤ complexity")
    print("=" * 60)

    braids = [
        ("Identity", identity_braid(3)),
        ("Hopf link", hopf_braid(3)),
        ("Trefoil", trefoil_braid(3)),
        ("Figure-eight", figure_eight_braid(3)),
    ]

    for name, b in braids:
        info = b.info_content
        comp = b.crossing_number
        print(f"  {name:15s}: |writhe|={info}, crossings={comp}, "
              f"info ≤ complexity: {info} ≤ {comp} → {'✓' if info <= comp else '✗'}")
        assert info <= comp
    print()


def demo_cognitive_hierarchy():
    """Demonstrate the cognitive complexity hierarchy."""
    print("=" * 60)
    print("COGNITIVE COMPLEXITY HIERARCHY")
    print("=" * 60)

    braids = [
        ("Linear thought (identity)", identity_braid(3)),
        ("Simple association (Hopf)", hopf_braid(3)),
        ("Creative insight (trefoil)", trefoil_braid(3)),
        ("Confused thinking (fig-8)", figure_eight_braid(3)),
    ]

    for name, b in braids:
        print(f"  {name:35s}: crossings={b.crossing_number}, "
              f"level={b.cog_level()}, writhe={b.writhe}")
    print()


def demo_double_inverse():
    """Demonstrate Theorem: (w⁻¹)⁻¹ = w"""
    print("=" * 60)
    print("THEOREM: Double inverse is identity")
    print("=" * 60)

    w = figure_eight_braid(3)
    w_inv_inv = w.inv().inv()

    print(f"  w = {w}")
    print(f"  w⁻¹ = {w.inv()}")
    print(f"  (w⁻¹)⁻¹ = {w_inv_inv}")
    # Check generators match
    assert len(w.generators) == len(w_inv_inv.generators)
    for g1, g2 in zip(w.generators, w_inv_inv.generators):
        assert g1.index == g2.index and g1.positive == g2.positive
    print("  ✓ Verified: (w⁻¹)⁻¹ = w")
    print()


if __name__ == "__main__":
    print("\n🧠 COGNITIVE BRAIDS: Thinking as Topology\n")
    demo_writhe_additivity()
    demo_writhe_inverse()
    demo_info_bound()
    demo_cognitive_hierarchy()
    demo_double_inverse()
    print("All demonstrations verified successfully! ✓")


"""
Visualization 1: Cognitive Braid Diagrams

Visualizes canonical cognitive braids (identity, trefoil, figure-eight)
as strand diagrams, showing how neural pathways cross and interleave.
Each braid represents a different type of cognitive process.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_braid(ax, title, generators, n_strands=3, color_map=None):
    """
    Draw a braid diagram on the given axes.

    generators: list of (strand_index, sign) tuples
    """
    if color_map is None:
        color_map = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    segment_width = 1.5
    total_width = len(generators) * segment_width + 1
    strand_spacing = 1.0

    # Track strand positions
    positions = list(range(n_strands))

    # Draw each crossing
    x_start = 0.5
    for seg_idx, (strand_idx, sign) in enumerate(generators):
        x = x_start + seg_idx * segment_width
        x_next = x + segment_width

        # Draw all strands
        for s in range(n_strands):
            pos = positions[s]
            if s == strand_idx or s == strand_idx + 1:
                continue
            # Straight strand
            ax.plot([x, x_next], [pos * strand_spacing, pos * strand_spacing],
                    color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

        # Draw crossing strands
        top_strand = strand_idx if sign == 1 else strand_idx + 1
        bot_strand = strand_idx + 1 if sign == 1 else strand_idx

        top_pos = positions[top_strand] * strand_spacing
        bot_pos = positions[bot_strand] * strand_spacing

        # Over strand (continuous)
        t = np.linspace(0, 1, 50)
        over_y = top_pos + (bot_pos - top_pos) * (0.5 - 0.5 * np.cos(np.pi * t))
        ax.plot(x + t * segment_width, over_y,
                color=color_map[top_strand % len(color_map)], linewidth=4,
                solid_capstyle='round', zorder=3)

        # Under strand (with gap)
        under_y = bot_pos + (top_pos - bot_pos) * (0.5 - 0.5 * np.cos(np.pi * t))
        gap_mask = (t > 0.35) & (t < 0.65)
        under_y_masked = np.ma.array(under_y, mask=gap_mask)
        ax.plot(x + t * segment_width, under_y_masked,
                color=color_map[bot_strand % len(color_map)], linewidth=3,
                solid_capstyle='round', zorder=2)

        # Update positions
        positions[top_strand], positions[bot_strand] = positions[bot_strand], positions[top_strand]

    # Draw final straight segments
    x_end = x_start + len(generators) * segment_width
    for s in range(n_strands):
        pos = positions[s] * strand_spacing
        ax.plot([x_end, x_end + 0.5], [pos, pos],
                color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

    # Draw initial straight segments
    # Reset positions for initial
    init_pos = list(range(n_strands))
    for s in range(n_strands):
        pos = init_pos[s] * strand_spacing
        ax.plot([0, 0.5], [pos, pos],
                color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

    ax.set_xlim(-0.3, total_width + 0.3)
    ax.set_ylim(-0.5, (n_strands - 0.5) * strand_spacing)
    ax.set_title(title, fontsize=14, fontweight='bold', pad=10)
    ax.set_aspect('equal')
    ax.axis('off')


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Cognitive Braid Diagrams: Thinking as Topology',
             fontsize=18, fontweight='bold', y=0.98)

# Identity braid (no crossings) — linear thought
ax = axes[0, 0]
draw_braid(ax, 'Identity Braid\n(Linear Thought)\nWrithe = 0, Level = trivial', [], n_strands=3)

# Trefoil braid (σ₁³) — creative insight
ax = axes[0, 1]
draw_braid(ax, 'Trefoil Braid (σ₁³)\n(Creative Insight)\nWrithe = 3, Level = moderate',
           [(0, 1), (0, 1), (0, 1)], n_strands=3)

# Figure-eight braid — confused thinking
ax = axes[1, 0]
draw_braid(ax, 'Figure-Eight Braid (σ₁σ₂⁻¹σ₁σ₂⁻¹)\n(Confused Thinking)\nWrithe = 0, Level = moderate',
           [(0, 1), (1, -1), (0, 1), (1, -1)], n_strands=3)

# Full twist braid — deep focus
ax = axes[1, 1]
draw_braid(ax, 'Full Twist (σ₁σ₂σ₁σ₂σ₁σ₂)\n(Deep Focus)\nWrithe = 6, Level = complex',
           [(0, 1), (1, 1), (0, 1), (1, 1), (0, 1), (1, 1)], n_strands=3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_braid_strands.png', dpi=150, bbox_inches='tight')
print("Saved viz_braid_strands.png")


"""
Visualization 2: Cognitive Complexity Landscape

A heatmap showing the relationship between crossing number, writhe, and
cognitive complexity level. Demonstrates the proved theorem that
|writhe| ≤ crossing_number (the feasible region) and the cognitive
hierarchy (trivial → simple → moderate → complex).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# ─── Left panel: Writhe vs Crossing Number with feasibility region ────

max_crossings = 12
crossings = np.arange(0, max_crossings + 1)

# Feasible region: |writhe| ≤ crossing_number
# Also writhe ≡ crossing_number (mod 2) — proved theorem
for k in crossings:
    feasible_writhes = [w for w in range(-k, k + 1) if (w - k) % 2 == 0]
    for w in feasible_writhes:
        info = abs(w)
        if k == 0:
            color = '#95a5a6'  # trivial
        elif k <= 2:
            color = '#3498db'  # simple
        elif k <= 5:
            color = '#2ecc71'  # moderate
        else:
            color = '#e74c3c'  # complex

        size = max(20, 60 * (info / max(k, 1)))
        ax1.scatter(k, w, s=size + 30, c=color, alpha=0.7, edgecolors='white', linewidth=0.5)

# Mark special braids
special_braids = [
    (0, 0, 'Identity\n(No thought)', '#95a5a6'),
    (2, 2, 'Hopf link\n(Paired)', '#3498db'),
    (3, 3, 'Trefoil\n(Creative)', '#2ecc71'),
    (4, 0, 'Figure-8\n(Confused)', '#2ecc71'),
    (6, 6, 'Full twist\n(Deep focus)', '#e74c3c'),
]

for cx, wr, label, color in special_braids:
    ax1.scatter(cx, wr, s=200, c=color, edgecolors='black', linewidth=2, zorder=5)
    offset_x = 0.4 if cx < 5 else -0.4
    offset_y = 0.8
    ax1.annotate(label, (cx, wr), xytext=(cx + offset_x, wr + offset_y),
                fontsize=8, fontweight='bold', ha='center',
                arrowprops=dict(arrowstyle='->', color='gray', lw=0.8))

# Draw feasibility boundary
ax1.plot(crossings, crossings, 'k--', alpha=0.5, label='|writhe| = crossings')
ax1.plot(crossings, -crossings, 'k--', alpha=0.5)
ax1.fill_between(crossings, -crossings, crossings, alpha=0.05, color='blue')

ax1.set_xlabel('Crossing Number (Complexity)', fontsize=12)
ax1.set_ylabel('Writhe (Algebraic Crossing Number)', fontsize=12)
ax1.set_title('Cognitive Braid Space\n|writhe| ≤ crossings (proved)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Add cognitive level bands
for (xmin, xmax, label, color) in [(0, 0.5, 'Trivial', '#95a5a6'),
                                     (0.5, 2.5, 'Simple', '#3498db'),
                                     (2.5, 5.5, 'Moderate', '#2ecc71'),
                                     (5.5, 12.5, 'Complex', '#e74c3c')]:
    ax1.axvspan(xmin, xmax, alpha=0.08, color=color)

# ─── Right panel: Information content vs complexity ────────────

# Generate random braids and compute their invariants
np.random.seed(42)
n_samples = 200
data_crossings = []
data_info = []
data_levels = []

for _ in range(n_samples):
    k = np.random.randint(0, 13)
    # Random writhe with correct parity
    if k == 0:
        w = 0
    else:
        possible = [x for x in range(-k, k + 1) if (x - k) % 2 == 0]
        w = np.random.choice(possible)
    data_crossings.append(k)
    data_info.append(abs(w))
    if k == 0: data_levels.append(0)
    elif k <= 2: data_levels.append(1)
    elif k <= 5: data_levels.append(2)
    else: data_levels.append(3)

level_colors = ['#95a5a6', '#3498db', '#2ecc71', '#e74c3c']
level_names = ['Trivial', 'Simple', 'Moderate', 'Complex']

for level in range(4):
    mask = [l == level for l in data_levels]
    cx = [data_crossings[i] for i in range(n_samples) if mask[i]]
    info = [data_info[i] for i in range(n_samples) if mask[i]]
    ax2.scatter(cx, info, c=level_colors[level], label=level_names[level],
               alpha=0.6, s=30, edgecolors='white', linewidth=0.3)

# Theoretical bound line
x_line = np.linspace(0, 12, 100)
ax2.plot(x_line, x_line, 'k-', linewidth=2, label='info = complexity (upper bound)')
ax2.fill_between(x_line, 0, x_line, alpha=0.05, color='green')

ax2.set_xlabel('Crossing Number (Complexity)', fontsize=12)
ax2.set_ylabel('Information Content |writhe|', fontsize=12)
ax2.set_title('Information ≤ Complexity\n(Shannon-type bound, proved)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 12.5)
ax2.set_ylim(-0.5, 12.5)

plt.tight_layout()
plt.savefig('viz_complexity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_landscape.png")


"""
Visualization 3: Cognitive Complexity Hierarchy

Visualizes the monotonicity of the cognitive level assignment and
the information-theoretic bounds. Shows how the proved theorems
constrain the space of possible cognitive processes.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ─── Left: Cognitive Level Step Function (Monotonicity) ────────

crossings = np.arange(0, 15)
level_names = ['Trivial', 'Simple', 'Moderate', 'Complex']
level_colors = ['#95a5a6', '#3498db', '#2ecc71', '#e74c3c']

def cog_level(k):
    if k == 0: return 0
    elif k <= 2: return 1
    elif k <= 5: return 2
    else: return 3

levels = [cog_level(k) for k in crossings]

# Step function
for i in range(len(crossings) - 1):
    ax1.fill_between([crossings[i], crossings[i+1]],
                     [levels[i], levels[i]],
                     alpha=0.3, color=level_colors[levels[i]])
    ax1.plot([crossings[i], crossings[i+1]], [levels[i], levels[i]],
             color=level_colors[levels[i]], linewidth=3)

# Transition markers
transitions = [(0, 1, 1), (2, 3, 2), (5, 6, 3)]
for x1, x2, new_level in transitions:
    ax1.annotate('', xy=(x2, new_level), xytext=(x1, new_level - 1),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))

# Labels
for i, name in enumerate(level_names):
    positions = [k for k in crossings if cog_level(k) == i]
    if positions:
        mid = (min(positions) + max(positions)) / 2
        ax1.text(mid, i + 0.15, name, ha='center', va='bottom',
                fontsize=11, fontweight='bold', color=level_colors[i])

ax1.set_xlabel('Crossing Number', fontsize=12)
ax1.set_ylabel('Cognitive Level Rank', fontsize=12)
ax1.set_title('Cognitive Hierarchy is Monotone\n(Proved: a ≤ b → rank(a) ≤ rank(b))',
             fontsize=13, fontweight='bold')
ax1.set_yticks([0, 1, 2, 3])
ax1.set_yticklabels(level_names)
ax1.grid(True, alpha=0.3, axis='x')
ax1.set_xlim(-0.5, 14.5)
ax1.set_ylim(-0.3, 3.8)

# ─── Right: Writhe Parity Theorem ────────────────────────────

ax2_data = []
for k in range(0, 11):
    feasible = [w for w in range(-k, k + 1) if (w - k) % 2 == 0]
    infeasible = [w for w in range(-k, k + 1) if (w - k) % 2 != 0]
    for w in feasible:
        ax2.scatter(k, w, s=60, c='#2ecc71', alpha=0.7, edgecolors='white', linewidth=0.5)
    for w in infeasible:
        ax2.scatter(k, w, s=20, c='#e74c3c', alpha=0.3, marker='x')

# Boundary
k_range = np.arange(0, 11)
ax2.plot(k_range, k_range, 'k--', alpha=0.4, linewidth=1)
ax2.plot(k_range, -k_range, 'k--', alpha=0.4, linewidth=1)

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2ecc71', markersize=10,
           label='Feasible (writhe ≡ crossings mod 2)'),
    Line2D([0], [0], marker='x', color='#e74c3c', markersize=8,
           label='Infeasible (parity violation)'),
]
ax2.legend(handles=legend_elements, fontsize=9, loc='upper left')

ax2.set_xlabel('Crossing Number k', fontsize=12)
ax2.set_ylabel('Writhe w', fontsize=12)
ax2.set_title('Writhe Parity Constraint\n(Proved: w ≡ k mod 2)',
             fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 10.5)

plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy.png")

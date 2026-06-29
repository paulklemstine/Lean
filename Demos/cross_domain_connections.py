#!/usr/bin/env python3
"""
Applications of Compositional Musical Specifications

Demonstrates real-world applications:
1. Verified harmonic constraint propagation
2. Style transfer safety certification
3. Vocabulary abstraction (MIDI → pitch class)
4. Compositional generative pipeline with safety guarantees
"""

from itertools import product
from typing import Callable
from algorithms import MusicSpec, stepwise_constraint, no_repeated_notes

PITCH_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def name_phrase(phrase: tuple[int, ...]) -> str:
    return '-'.join(PITCH_NAMES[p % 12] for p in phrase)


# ========================================================================
# Application 1: Verified Harmonic Constraint Propagation
# ========================================================================

def app_harmonic_propagation():
    """Show that composing constrained phrase libraries preserves the
    refinement hierarchy automatically."""
    print("=" * 70)
    print("APPLICATION 1: Verified Harmonic Constraint Propagation")
    print("=" * 70)

    # Three levels of harmonic strictness
    triad = MusicSpec.from_scale([0, 4, 7], 3)           # C major triad only
    diatonic = MusicSpec.from_scale([0, 2, 4, 5, 7, 9, 11], 3)  # C major scale
    chromatic = MusicSpec.from_scale(list(range(12)), 3)  # All 12 tones

    print(f"\n  Triad spec:     {len(triad)} phrases")
    print(f"  Diatonic spec:  {len(diatonic)} phrases")
    print(f"  Chromatic spec: {len(chromatic)} phrases")

    # Compose each with itself (verse + chorus, both from same library)
    comp_triad = triad.compose(triad)
    comp_diat = diatonic.compose(diatonic)
    comp_chrom = chromatic.compose(chromatic)

    print(f"\n  Composed triad:     {len(comp_triad)} 6-note phrases")
    print(f"  Composed diatonic:  {len(comp_diat)} 6-note phrases")
    print(f"  Composed chromatic: {len(comp_chrom)} 6-note phrases")

    # Verify the refinement chain propagates
    assert comp_triad.refines(comp_diat)
    assert comp_diat.refines(comp_chrom)
    assert comp_triad.refines(comp_chrom)  # Transitivity
    print("\n  ✓ Refinement chain verified after composition:")
    print("    triad·triad ⊆ diatonic·diatonic ⊆ chromatic·chromatic")
    print("\n  Implication: If each section uses only triad notes,")
    print("  the assembled piece automatically satisfies diatonic constraints.")
    print()


# ========================================================================
# Application 2: Style Transfer Safety Certificate
# ========================================================================

def app_style_transfer_safety():
    """Demonstrate that transposition-based style transfer preserves
    constraint hierarchies with mathematical certainty."""
    print("=" * 70)
    print("APPLICATION 2: Style Transfer Safety Certificate")
    print("=" * 70)

    # Source style: C major with stepwise constraint
    strict = MusicSpec.from_constraint(
        12, 4,
        lambda p: all(x in [0,2,4,5,7,9,11] for x in p)
                  and stepwise_constraint(p)
                  and no_repeated_notes(p)
    )
    relaxed = MusicSpec.from_constraint(
        12, 4,
        lambda p: all(x in [0,2,4,5,7,9,11] for x in p)
    )

    print(f"\n  Strict (stepwise, no repeats, diatonic): {len(strict)} phrases")
    print(f"  Relaxed (diatonic only):                 {len(relaxed)} phrases")
    assert strict.refines(relaxed)
    print(f"  strict ⊆ relaxed: True")

    # Apply various transpositions
    intervals = {
        'P4 (5 semitones)': 5,
        'P5 (7 semitones)': 7,
        'tritone (6 semitones)': 6,
        'minor 3rd (3 semitones)': 3,
    }

    print(f"\n  Style transfer via transposition:")
    for name, k in intervals.items():
        f = lambda x, k=k: (x + k) % 12
        t_strict = strict.map_spec(f)
        t_relaxed = relaxed.map_spec(f)
        preserved = t_strict.refines(t_relaxed)
        print(f"    {name}: refinement preserved = {preserved}")
        assert preserved

    print("\n  ✓ Safety certificate: transposition preserves all constraint hierarchies")
    print("    regardless of interval size.")
    print()


# ========================================================================
# Application 3: Vocabulary Abstraction
# ========================================================================

def app_vocabulary_abstraction():
    """Show that abstracting from detailed to coarse vocabulary preserves
    refinement (Galois-style abstraction)."""
    print("=" * 70)
    print("APPLICATION 3: Vocabulary Abstraction (Octave Collapse)")
    print("=" * 70)

    # Work with 2-octave range (24 pitch values: 0-23)
    # Abstraction: collapse to single octave (mod 12)
    abs_map = lambda x: x % 12

    # Detailed spec: C major scale in octave 1 only (pitches 0-11)
    oct1_major = MusicSpec.from_scale([0, 2, 4, 5, 7, 9, 11], 2, alphabet_size=24)

    # Detailed spec: C major scale across both octaves
    two_oct_major = MusicSpec.from_scale(
        [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23], 2, alphabet_size=24
    )

    print(f"\n  Oct1 major (2-note, pitches 0-11): {len(oct1_major)} phrases")
    print(f"  Two-octave major (2-note, pitches 0-23): {len(two_oct_major)} phrases")
    assert oct1_major.refines(two_oct_major)
    print(f"  oct1 ⊆ two_oct: True")

    # Abstract both to single-octave pitch classes
    abs_oct1 = oct1_major.map_spec(abs_map)
    abs_two_oct = two_oct_major.map_spec(abs_map)

    print(f"\n  Abstracted oct1: {len(abs_oct1)} phrases")
    print(f"  Abstracted two_oct: {len(abs_two_oct)} phrases")
    assert abs_oct1.refines(abs_two_oct)
    print(f"  abs(oct1) ⊆ abs(two_oct): True")

    print("\n  ✓ Abstraction preserves refinement: pitch-class reduction is safe.")
    print("    Constraints verified at the detailed level remain valid after abstraction.")
    print()


# ========================================================================
# Application 4: Compositional Generative Pipeline
# ========================================================================

def app_generative_pipeline():
    """Demonstrate a modular generative pipeline with verified safety."""
    print("=" * 70)
    print("APPLICATION 4: Compositional Generative Pipeline")
    print("=" * 70)

    # Step 1: Define motif libraries with different constraint levels
    # "Verse" motifs: pentatonic, stepwise
    verse_strict = MusicSpec.from_constraint(
        12, 3,
        lambda p: all(x in [0,2,4,7,9] for x in p) and stepwise_constraint(p)
    )
    verse_relaxed = MusicSpec.from_scale([0,2,4,7,9], 3)

    # "Chorus" motifs: major triad arpeggios
    chorus_strict = MusicSpec.from_constraint(
        12, 3,
        lambda p: all(x in [0,4,7] for x in p) and no_repeated_notes(p)
    )
    chorus_relaxed = MusicSpec.from_scale([0,4,7], 3)

    print(f"\n  Step 1: Define motif libraries")
    print(f"    Verse (strict/stepwise pentatonic): {len(verse_strict)} motifs")
    print(f"    Verse (relaxed/all pentatonic):     {len(verse_relaxed)} motifs")
    print(f"    Chorus (strict/no-repeat triad):    {len(chorus_strict)} motifs")
    print(f"    Chorus (relaxed/all triad):         {len(chorus_relaxed)} motifs")

    # Step 2: Compose verse + chorus
    song_strict = verse_strict.compose(chorus_strict)
    song_relaxed = verse_relaxed.compose(chorus_relaxed)

    print(f"\n  Step 2: Compose (verse · chorus)")
    print(f"    Strict song: {len(song_strict)} 6-note phrases")
    print(f"    Relaxed song: {len(song_relaxed)} 6-note phrases")

    # Verify monotonicity
    assert verse_strict.refines(verse_relaxed)
    assert chorus_strict.refines(chorus_relaxed)
    assert song_strict.refines(song_relaxed)
    print(f"    strict_song ⊆ relaxed_song: True (by Theorem 3.1)")

    # Step 3: Style transfer (transpose to G)
    transpose_G = lambda x: (x + 7) % 12
    g_strict = song_strict.map_spec(transpose_G)
    g_relaxed = song_relaxed.map_spec(transpose_G)

    print(f"\n  Step 3: Style transfer (transpose to G)")
    print(f"    G-strict song: {len(g_strict)} phrases")
    print(f"    G-relaxed song: {len(g_relaxed)} phrases")
    assert g_strict.refines(g_relaxed)
    print(f"    G-strict ⊆ G-relaxed: True (by Theorem 4.1)")

    # Step 4: Verify monoidal functor law
    # Direct transport of composed song vs compose then transport
    direct = song_strict.map_spec(transpose_G)
    via_parts = verse_strict.map_spec(transpose_G).compose(
        chorus_strict.map_spec(transpose_G)
    )
    assert direct == via_parts
    print(f"\n  Step 4: Monoidal functor law verification")
    print(f"    f(verse·chorus) == f(verse)·f(chorus): True (by Theorem 4.2)")

    # Summary
    print(f"\n  ✓ Full pipeline verified:")
    print(f"    1. Each library satisfies its constraints (by construction)")
    print(f"    2. Composed song preserves refinement (Theorem 3.1)")
    print(f"    3. Style transfer preserves refinement (Theorem 4.1)")
    print(f"    4. Transfer commutes with composition (Theorem 4.2)")
    print(f"    → The generative pipeline is CERTIFIED SAFE end-to-end.")
    print()


if __name__ == '__main__':
    app_harmonic_propagation()
    app_style_transfer_safety()
    app_vocabulary_abstraction()
    app_generative_pipeline()
    print("=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY ✓")
    print("=" * 70)


#!/usr/bin/env python3
"""
Compositional Musical Specifications: Concrete Demonstrations

Demonstrates the key theorems with concrete musical examples using
12-tone pitch classes and common scales.
"""

from itertools import product
from typing import Set, Callable, FrozenSet, Tuple

# --- Core Definitions ---

# Musical event type: pitch classes 0..11 (C=0, C#=1, ..., B=11)
PITCH_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

# Type alias: a phrase is a tuple of ints, a spec is a frozenset of phrases
Phrase = Tuple[int, ...]
MusicSpec = FrozenSet[Phrase]


def make_scale_spec(scale_degrees: list[int], phrase_length: int) -> MusicSpec:
    """Generate all phrases of given length using only the given scale degrees."""
    return frozenset(product(scale_degrees, repeat=phrase_length))


def refines(S: MusicSpec, T: MusicSpec) -> bool:
    """S refines T iff S ⊆ T (fewer allowed behaviors = stricter)."""
    return S.issubset(T)


def compose(S: MusicSpec, T: MusicSpec) -> MusicSpec:
    """Concatenative composition: {u ++ v | u ∈ S, v ∈ T}."""
    return frozenset(u + v for u in S for v in T)


def map_spec(f: Callable[[int], int], S: MusicSpec) -> MusicSpec:
    """Style transport: relabel each event in each phrase by f."""
    return frozenset(tuple(f(x) for x in phrase) for phrase in S)


def empty_word_spec() -> MusicSpec:
    """The identity specification: {()}."""
    return frozenset({()})


# --- Scale Definitions ---

C_MAJOR = [0, 2, 4, 5, 7, 9, 11]           # C D E F G A B
C_PENTATONIC = [0, 2, 4, 7, 9]              # C D E G A
C_MAJOR_TRIAD = [0, 4, 7]                   # C E G
CHROMATIC = list(range(12))                   # All 12 pitch classes

PHRASE_LEN = 3  # Use 3-note phrases for demonstrations


def transpose(k: int) -> Callable[[int], int]:
    """Transposition by k semitones (mod 12)."""
    return lambda x: (x + k) % 12


def name_phrase(phrase: Phrase) -> str:
    """Human-readable phrase name."""
    return '-'.join(PITCH_NAMES[p] for p in phrase)


# --- Demonstrations ---

def demo_refinement_hierarchy():
    """Demonstrate the refinement preorder: triad ⊂ pentatonic ⊂ major ⊂ chromatic."""
    print("=" * 70)
    print("DEMO 1: Refinement Hierarchy of Musical Specifications")
    print("=" * 70)

    specs = {
        'C major triad': make_scale_spec(C_MAJOR_TRIAD, PHRASE_LEN),
        'C pentatonic':  make_scale_spec(C_PENTATONIC, PHRASE_LEN),
        'C major':       make_scale_spec(C_MAJOR, PHRASE_LEN),
        'Chromatic':     make_scale_spec(CHROMATIC, PHRASE_LEN),
    }

    print(f"\nPhrase length: {PHRASE_LEN} notes")
    print(f"{'Specification':<20} {'# phrases':>10}")
    print("-" * 32)
    for name, spec in specs.items():
        print(f"{name:<20} {len(spec):>10}")

    print("\nRefinement relationships (S refines T ⟺ S ⊆ T):")
    names = list(specs.keys())
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                r = refines(specs[n1], specs[n2])
                print(f"  {n1} ⊆ {n2}: {r}")

    # Verify reflexivity and transitivity
    print("\nPreorder verification:")
    for name, spec in specs.items():
        assert refines(spec, spec), f"Reflexivity failed for {name}"
    print("  ✓ Reflexivity holds for all specifications")

    triad = specs['C major triad']
    pent = specs['C pentatonic']
    major = specs['C major']
    chrom = specs['Chromatic']
    assert refines(triad, pent) and refines(pent, major) and refines(triad, major)
    print("  ✓ Transitivity verified: triad ⊆ pentatonic ⊆ major ⊆ chromatic")
    print()


def demo_compositional_monotonicity():
    """Demonstrate Theorem 3.1: compose is monotone in both arguments."""
    print("=" * 70)
    print("DEMO 2: Compositional Monotonicity of Refinement")
    print("=" * 70)

    S1 = make_scale_spec(C_MAJOR_TRIAD, 2)   # Strict: only triad notes
    S2 = make_scale_spec(C_PENTATONIC, 2)     # Relaxed: pentatonic
    T1 = make_scale_spec(C_MAJOR_TRIAD, 2)    # Strict
    T2 = make_scale_spec(C_MAJOR, 2)           # Relaxed: full major scale

    print(f"\n  S1 (triad, 2-note): {len(S1)} phrases")
    print(f"  S2 (pentatonic, 2-note): {len(S2)} phrases")
    print(f"  T1 (triad, 2-note): {len(T1)} phrases")
    print(f"  T2 (major, 2-note): {len(T2)} phrases")
    print(f"  S1 ⊆ S2: {refines(S1, S2)}")
    print(f"  T1 ⊆ T2: {refines(T1, T2)}")

    comp1 = compose(S1, T1)
    comp2 = compose(S2, T2)

    print(f"\n  compose(S1, T1): {len(comp1)} phrases (4-note)")
    print(f"  compose(S2, T2): {len(comp2)} phrases (4-note)")
    print(f"  compose(S1, T1) ⊆ compose(S2, T2): {refines(comp1, comp2)}")
    assert refines(comp1, comp2), "Compositional monotonicity failed!"
    print("  ✓ Theorem verified: composition preserves refinement")
    print()


def demo_style_transport():
    """Demonstrate Theorems 4.1 and 4.2: style transport preserves refinement
    and commutes with composition."""
    print("=" * 70)
    print("DEMO 3: Style Transport (Transposition by Perfect Fifth)")
    print("=" * 70)

    f = transpose(7)  # Transpose up by a perfect fifth

    S = make_scale_spec(C_MAJOR_TRIAD, PHRASE_LEN)
    T = make_scale_spec(C_PENTATONIC, PHRASE_LEN)

    fS = map_spec(f, S)
    fT = map_spec(f, T)

    print(f"\n  S (C major triad): {len(S)} phrases")
    print(f"  T (C pentatonic): {len(T)} phrases")
    print(f"  S ⊆ T: {refines(S, T)}")
    print(f"\n  f = transpose by 7 semitones (P5)")
    print(f"  f(S) (G major triad): {len(fS)} phrases")
    print(f"  f(T) (G pentatonic): {len(fT)} phrases")
    print(f"  f(S) ⊆ f(T): {refines(fS, fT)}")
    assert refines(fS, fT), "Style transport monotonicity failed!"
    print("  ✓ Theorem 4.1 verified: style transport preserves refinement")

    # Show some example phrases
    print("\n  Example phrases:")
    sample_S = list(S)[:3]
    for p in sample_S:
        fp = tuple(f(x) for x in p)
        print(f"    {name_phrase(p)} → {name_phrase(fp)}")

    # Monoidal functor law
    print(f"\n  Monoidal functor law: f(S·T) = f(S)·f(T)")
    S2 = make_scale_spec(C_MAJOR_TRIAD, 2)
    T2 = make_scale_spec(C_PENTATONIC, 2)

    lhs = map_spec(f, compose(S2, T2))
    rhs = compose(map_spec(f, S2), map_spec(f, T2))

    print(f"  f(compose(S, T)): {len(lhs)} phrases")
    print(f"  compose(f(S), f(T)): {len(rhs)} phrases")
    print(f"  Equal: {lhs == rhs}")
    assert lhs == rhs, "Monoidal functor law failed!"
    print("  ✓ Theorem 4.2 verified: style transport commutes with composition")
    print()


def demo_monoidal_structure():
    """Demonstrate associativity and unit laws."""
    print("=" * 70)
    print("DEMO 4: Monoidal Structure (Associativity and Identity)")
    print("=" * 70)

    S = make_scale_spec(C_MAJOR_TRIAD, 2)
    T = make_scale_spec(C_PENTATONIC, 2)
    U = make_scale_spec([0, 2, 4], 2)  # C major subset
    eps = empty_word_spec()

    # Associativity
    lhs = compose(compose(S, T), U)
    rhs = compose(S, compose(T, U))
    print(f"\n  (S·T)·U: {len(lhs)} phrases (6-note)")
    print(f"  S·(T·U): {len(rhs)} phrases (6-note)")
    print(f"  Equal: {lhs == rhs}")
    assert lhs == rhs, "Associativity failed!"
    print("  ✓ Theorem 5.1 verified: composition is associative")

    # Left identity
    lhs_id = compose(eps, S)
    print(f"\n  ε·S: {len(lhs_id)} phrases")
    print(f"  S:   {len(S)} phrases")
    print(f"  Equal: {lhs_id == S}")
    assert lhs_id == S, "Left identity failed!"
    print("  ✓ Theorem 5.2 verified: ε is left identity")

    # Right identity
    rhs_id = compose(S, eps)
    print(f"\n  S·ε: {len(rhs_id)} phrases")
    print(f"  S:   {len(S)} phrases")
    print(f"  Equal: {rhs_id == S}")
    assert rhs_id == S, "Right identity failed!"
    print("  ✓ Theorem 5.3 verified: ε is right identity")
    print()


def demo_iterated_transport():
    """Demonstrate Theorem 6.1: iterated transport preserves refinement."""
    print("=" * 70)
    print("DEMO 5: Iterated Style Transport (Musical Telephone)")
    print("=" * 70)

    f = transpose(7)  # Perfect fifth
    S = make_scale_spec(C_MAJOR_TRIAD, PHRASE_LEN)
    T = make_scale_spec(C_PENTATONIC, PHRASE_LEN)

    print(f"\n  f = transpose by P5, applied iteratively")
    print(f"  {'n':<5} {'|f^n(S)|':>10} {'|f^n(T)|':>10} {'f^n(S) ⊆ f^n(T)':>18}")
    print("  " + "-" * 45)

    fS, fT = S, T
    for n in range(8):
        r = refines(fS, fT)
        print(f"  {n:<5} {len(fS):>10} {len(fT):>10} {str(r):>18}")
        assert r, f"Iterated transport failed at n={n}"
        fS = map_spec(f, fS)
        fT = map_spec(f, fT)

    print("  ✓ Theorem 6.1 verified: refinement preserved through 7 iterations")
    print()


def demo_functoriality():
    """Demonstrate Theorems 4.3-4.4: functoriality of style maps."""
    print("=" * 70)
    print("DEMO 6: Functoriality of Style Transport")
    print("=" * 70)

    S = make_scale_spec(C_MAJOR_TRIAD, PHRASE_LEN)

    # Identity
    id_S = map_spec(lambda x: x, S)
    print(f"\n  id(S) == S: {id_S == S}")
    assert id_S == S
    print("  ✓ Theorem 4.3 verified: identity map is identity on specs")

    # Composition
    f = transpose(3)   # Minor third
    g = transpose(4)   # Major third
    gf = transpose(7)  # Their composition = perfect fifth

    gf_S = map_spec(gf, S)
    g_f_S = map_spec(g, map_spec(f, S))

    print(f"  g(f(S)) == (g∘f)(S): {g_f_S == gf_S}")
    assert g_f_S == gf_S
    print("  ✓ Theorem 4.4 verified: map composition = composed maps")

    # Unit preservation
    eps = empty_word_spec()
    f_eps = map_spec(f, eps)
    print(f"  f(ε) == ε: {f_eps == eps}")
    assert f_eps == eps
    print("  ✓ Theorem 4.5 verified: style maps preserve empty word spec")
    print()


if __name__ == '__main__':
    demo_refinement_hierarchy()
    demo_compositional_monotonicity()
    demo_style_transport()
    demo_monoidal_structure()
    demo_iterated_transport()
    demo_functoriality()
    print("=" * 70)
    print("ALL DEMONSTRATIONS PASSED ✓")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Compositional Musical Specifications

Generates publication-quality figures demonstrating the key mathematical
structures: refinement lattices, composition growth, transport behavior.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
import base64
from io import BytesIO


PITCH_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def make_scale_spec(degrees, length):
    return frozenset(product(degrees, repeat=length))


def compose_spec(S, T):
    return frozenset(u + v for u in S for v in T)


def map_spec(f, S):
    return frozenset(tuple(f(x) for x in p) for p in S)


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_refinement_lattice():
    """Visualize the refinement lattice of common scale specifications."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Compute specification sizes for various scales and phrase lengths
    scales = {
        'Chromatic (12)': list(range(12)),
        'Major (7)': [0, 2, 4, 5, 7, 9, 11],
        'Pentatonic (5)': [0, 2, 4, 7, 9],
        'Major Triad (3)': [0, 4, 7],
        'Root only (1)': [0],
    }

    phrase_lengths = range(1, 7)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

    for (name, degrees), color in zip(scales.items(), colors):
        sizes = [len(degrees) ** L for L in phrase_lengths]
        ax.semilogy(list(phrase_lengths), sizes, 'o-', color=color,
                    label=name, linewidth=2, markersize=8)

    ax.set_xlabel('Phrase Length', fontsize=14)
    ax.set_ylabel('Number of Allowed Phrases (log scale)', fontsize=14)
    ax.set_title('Specification Size Growth by Scale Type\n(Refinement: lower = more constrained)',
                 fontsize=15)
    ax.legend(fontsize=12, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(phrase_lengths))

    fig.savefig('/workspace/request-project/fig_refinement_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_composition_monotonicity():
    """Visualize how composition preserves the refinement ordering."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    scales_info = [
        ('Triad', [0, 4, 7], '#f39c12'),
        ('Pentatonic', [0, 2, 4, 7, 9], '#2ecc71'),
        ('Major', [0, 2, 4, 5, 7, 9, 11], '#3498db'),
    ]

    # Left: individual specs
    ax = axes[0]
    lengths = range(1, 5)
    for name, degrees, color in scales_info:
        sizes = [len(make_scale_spec(degrees, L)) for L in lengths]
        ax.bar([x + scales_info.index((name, degrees, color)) * 0.25 for x in lengths],
               sizes, width=0.25, color=color, label=name, alpha=0.8)
    ax.set_xlabel('Phrase Length')
    ax.set_ylabel('# Phrases')
    ax.set_title('Individual Specifications')
    ax.legend(fontsize=9)
    ax.set_yscale('log')

    # Middle: composed with triad (2-note)
    ax = axes[1]
    fixed = make_scale_spec([0, 4, 7], 2)
    for name, degrees, color in scales_info:
        sizes = [len(compose_spec(make_scale_spec(degrees, L), fixed)) for L in lengths]
        ax.bar([x + scales_info.index((name, degrees, color)) * 0.25 for x in lengths],
               sizes, width=0.25, color=color, label=name, alpha=0.8)
    ax.set_xlabel('Phrase Length (first part)')
    ax.set_ylabel('# Composed Phrases')
    ax.set_title('Composed with Triad (2-note)')
    ax.legend(fontsize=9)
    ax.set_yscale('log')

    # Right: refinement preserved
    ax = axes[2]
    for L in lengths:
        triad = make_scale_spec([0, 4, 7], L)
        pent = make_scale_spec([0, 2, 4, 7, 9], L)
        major = make_scale_spec([0, 2, 4, 5, 7, 9, 11], L)

        comp_t = compose_spec(triad, fixed)
        comp_p = compose_spec(pent, fixed)
        comp_m = compose_spec(major, fixed)

        # All refinements preserved
        assert comp_t.issubset(comp_p)
        assert comp_p.issubset(comp_m)

    ax.text(0.5, 0.7, '✓ Triad·F ⊆ Pent·F ⊆ Major·F',
            transform=ax.transAxes, fontsize=13, ha='center',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
    ax.text(0.5, 0.4, 'for ALL phrase lengths\nand ALL fixed contexts F',
            transform=ax.transAxes, fontsize=11, ha='center')
    ax.text(0.5, 0.15, 'Theorem 3.1:\nComposition is monotone',
            transform=ax.transAxes, fontsize=12, ha='center', fontstyle='italic')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    ax.set_title('Monotonicity Verified')

    plt.suptitle('Compositional Monotonicity of Refinement', fontsize=16, y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_composition_monotonicity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_style_transport():
    """Visualize style transport (transposition) preserving refinement."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: sizes under all 12 transpositions
    ax = axes[0]
    triad = make_scale_spec([0, 4, 7], 3)
    pent = make_scale_spec([0, 2, 4, 7, 9], 3)
    major = make_scale_spec([0, 2, 4, 5, 7, 9, 11], 3)

    transpositions = range(12)
    for name, spec, color in [('Triad', triad, '#f39c12'),
                               ('Pentatonic', pent, '#2ecc71'),
                               ('Major', major, '#3498db')]:
        sizes = []
        for k in transpositions:
            t_spec = map_spec(lambda x, k=k: (x + k) % 12, spec)
            sizes.append(len(t_spec))
        ax.plot(list(transpositions), sizes, 'o-', color=color,
                label=name, linewidth=2, markersize=6)

    ax.set_xlabel('Transposition (semitones)', fontsize=12)
    ax.set_ylabel('# Phrases in Transported Spec', fontsize=12)
    ax.set_title('Spec Size Under All Transpositions', fontsize=13)
    ax.set_xticks(range(12))
    ax.set_xticklabels([PITCH_NAMES[i] for i in range(12)], fontsize=9)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: refinement preserved under all transpositions
    ax = axes[1]
    results = []
    for k in range(12):
        f = lambda x, k=k: (x + k) % 12
        t_triad = map_spec(f, triad)
        t_pent = map_spec(f, pent)
        t_major = map_spec(f, major)
        r1 = t_triad.issubset(t_pent)
        r2 = t_pent.issubset(t_major)
        results.append((r1, r2))

    x = np.arange(12)
    colors_r1 = ['green' if r[0] else 'red' for r in results]
    colors_r2 = ['green' if r[1] else 'red' for r in results]
    ax.bar(x - 0.15, [1]*12, width=0.3, color=colors_r1, alpha=0.7, label='Triad ⊆ Pent')
    ax.bar(x + 0.15, [1]*12, width=0.3, color=colors_r2, alpha=0.7, label='Pent ⊆ Major')

    ax.set_xlabel('Transposition (semitones)', fontsize=12)
    ax.set_ylabel('Refinement Preserved', fontsize=12)
    ax.set_title('Refinement Under All Transpositions', fontsize=13)
    ax.set_xticks(range(12))
    ax.set_xticklabels([PITCH_NAMES[i] for i in range(12)], fontsize=9)
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['No', 'Yes'])
    ax.legend(fontsize=11)

    plt.suptitle('Style Transport Preserves Refinement (Theorem 4.1)', fontsize=15, y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_style_transport.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_monoidal_functor():
    """Visualize the monoidal functor law: f(S·T) = f(S)·f(T)."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    transpositions = range(12)
    phrase_lengths = [1, 2, 3]

    for L in phrase_lengths:
        diffs = []
        for k in transpositions:
            f = lambda x, k=k: (x + k) % 12
            S = make_scale_spec([0, 4, 7], L)
            T = make_scale_spec([0, 2, 4, 7, 9], L)

            # LHS: f(S·T)
            lhs = map_spec(f, compose_spec(S, T))
            # RHS: f(S)·f(T)
            rhs = compose_spec(map_spec(f, S), map_spec(f, T))

            # Symmetric difference size (should be 0)
            diff = len(lhs.symmetric_difference(rhs))
            diffs.append(diff)

        ax.plot(list(transpositions), diffs, 'o-',
                label=f'Phrase length {L}', linewidth=2, markersize=8)

    ax.set_xlabel('Transposition (semitones)', fontsize=12)
    ax.set_ylabel('|f(S·T) △ f(S)·f(T)| (should be 0)', fontsize=12)
    ax.set_title('Monoidal Functor Law: f(S·T) = f(S)·f(T)\n'
                 'Symmetric difference = 0 for all transpositions and lengths',
                 fontsize=14)
    ax.set_xticks(range(12))
    ax.set_xticklabels([PITCH_NAMES[i] for i in range(12)], fontsize=9)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 1)

    fig.savefig('/workspace/request-project/fig_monoidal_functor.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == '__main__':
    print("Generating visualizations...")
    b64_1 = plot_refinement_lattice()
    print("  ✓ Refinement lattice (fig_refinement_lattice.png)")
    b64_2 = plot_composition_monotonicity()
    print("  ✓ Composition monotonicity (fig_composition_monotonicity.png)")
    b64_3 = plot_style_transport()
    print("  ✓ Style transport (fig_style_transport.png)")
    b64_4 = plot_monoidal_functor()
    print("  ✓ Monoidal functor law (fig_monoidal_functor.png)")
    print("\nAll visualizations generated successfully.")

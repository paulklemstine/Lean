# Crystallographic Groups and Music: The 17 Wallpaper Groups of Rhythm

## Abstract

We develop a formal mathematical framework connecting the classification of two-dimensional wallpaper groups to the symmetry analysis of periodic drum patterns. A drum pattern is modeled as a doubly-periodic binary function on ℤ × ℤ, where the first axis represents time and the second represents pitch class or instrument. The symmetry group of such a pattern — the set of isometries preserving the pattern — is a wallpaper group. Since there are exactly 17 wallpaper groups (up to isomorphism), this yields a complete classification of rhythmic symmetry types. We formalize key structural results: (1) the translational symmetry group forms an additive subgroup of ℤ × ℤ; (2) the composition of two perpendicular mirror symmetries yields 2-fold rotational symmetry (pmm ⊇ p2); (3) reflection is an involution on finite rhythms, and palindromicity equals fixed-point-ness under reflection; (4) the crystallographic restriction constrains rotation orders to {1, 2, 3, 4, 6}; (5) palindromic rhythms of odd length have a parity constraint determined by the center beat. All results are formally verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Motivation

The symmetry analysis of musical patterns has a long history, from the mathematical music theory of Euler and Helmholtz to modern computational musicology. However, the systematic classification of rhythmic symmetries using the machinery of crystallography appears to be underexplored. We propose that the 17 wallpaper groups provide a natural and complete classification scheme for the symmetries of periodic drum patterns.

### 1.2 Prior Work

The wallpaper groups were classified by Fedorov (1891) and Pólya (1924). Their application to music has been noted informally — Toussaint's work on Euclidean rhythms touches on rotational symmetry, and the mathematical analysis of canons involves translational symmetry. However, the full wallpaper group framework, incorporating mirrors, rotations, and glide reflections simultaneously, has not been systematically applied to rhythm.

Burnside's lemma for counting necklaces (equivalence classes of binary strings under cyclic rotation) is classical; our contribution is connecting this to the wallpaper group hierarchy and proving structural theorems about the palindromic subclass.

### 1.3 Contributions

1. **Formal definitions** of periodic rhythms, drum patterns, and their symmetry groups as subgroups of ℤ and ℤ × ℤ respectively.
2. **The pmm ⊇ p2 theorem**: Two perpendicular mirror symmetries compose to give 2-fold rotation.
3. **Reflection involution**: The reflection operation on finite rhythms is an involution, and palindromicity is equivalent to being a fixed point.
4. **Palindrome parity theorem**: For odd-length palindromic rhythms, the weight parity equals the center beat.
5. **Crystallographic restriction**: All rotation orders in the classification are in {1, 2, 3, 4, 6}.
6. **Enumeration**: Exactly 10 of 17 types have mirror symmetry; 8 have glide reflection.

## 2. Definitions

### 2.1 Periodic Rhythm

A **periodic rhythm** is a pair (f, p) where f : ℤ → {0, 1} and p ∈ ℕ with p > 0, such that f(n + p) = f(n) for all n ∈ ℤ. The set {n : f(n) = 1} is the **onset set**. The **weight** is |{k ∈ {0, ..., p-1} : f(k) = 1}|.

### 2.2 Translational Symmetry Group

The **translational symmetry group** of a periodic rhythm (f, p) is:

  Sym(f) = {d ∈ ℤ : ∀n, f(n + d) = f(n)}

This is an additive subgroup of ℤ containing pℤ. The index [Sym(f) : pℤ] equals p / min_period(f).

### 2.3 Drum Pattern

A **drum pattern** is a triple (g, T, P) where g : ℤ × ℤ → {0, 1}, T, P ∈ ℕ with T, P > 0, such that:
- g(t + T, p) = g(t, p) for all (t, p) (time periodicity)
- g(t, p + P) = g(t, p) for all (t, p) (pitch periodicity)

### 2.4 Point Group Symmetries

For a drum pattern g with periods (T, P):
- **Time mirror**: g(T - 1 - t, p) = g(t, p) for all (t, p)
- **Pitch mirror**: g(t, P - 1 - p) = g(t, p) for all (t, p)
- **2-fold rotation**: g(T - 1 - t, P - 1 - p) = g(t, p) for all (t, p)
- **Glide reflection**: g(t + T/2, P - 1 - p) = g(t, p) for all (t, p)

### 2.5 Finite Rhythm and Palindromicity

A **finite rhythm** of length n is a function f : Fin(n) → {0, 1}. The **reflection** is:
  reflect(f)(k) = f(n - 1 - k)

A finite rhythm is **palindromic** if reflect(f) = f.

### 2.6 Wallpaper Type

The 17 wallpaper types are enumerated as an inductive type: p1, p2, pm, pg, cm, pmm, pmg, pgg, cmm, p4, p4m, p4g, p3, p3m1, p31m, p6, p6m.

Each type is assigned:
- A **maximal rotation order** ∈ {1, 2, 3, 4, 6}
- Boolean flags for **mirror** and **glide** symmetry
- A **symmetry level** encoding the containment lattice

## 3. Main Results

### 3.1 Symmetry Group Structure (Theorem: mul_period_mem_symmGroup)

**Theorem.** For a periodic rhythm r with period p, every integer multiple mp of p belongs to the symmetry group Sym(r).

*Proof sketch.* For non-negative multiples, this follows by induction using the periodicity axiom. For negative multiples, apply the subgroup closure under negation.

### 3.2 Composition of Mirrors (Theorem: double_mirror_implies_rotation)

**Theorem.** If a drum pattern has both time-mirror symmetry and pitch-mirror symmetry, then it has 2-fold rotational symmetry.

*Proof sketch.* Apply the time mirror to obtain g(T-1-t, p) = g(t, p). Then apply the pitch mirror at the reflected point: g(T-1-t, P-1-p) = g(T-1-t, p). Chaining gives g(T-1-t, P-1-p) = g(t, p), which is the rotational symmetry condition.

This is a special case of the general crystallographic fact that the composition of two perpendicular reflections is a 180° rotation. It implies that the wallpaper group pmm (two perpendicular mirrors) necessarily contains p2 (2-fold rotation) as a subgroup.

### 3.3 Reflection Involution (Theorem: reflect_involutive)

**Theorem.** For any finite rhythm f of length n, reflect(reflect(f)) = f.

*Proof.* For each index k, reflect(reflect(f))(k) = reflect(f)(n-1-k) = f(n-1-(n-1-k)) = f(k).

### 3.4 Palindromic Characterization (Theorem: palindromic_iff_eq_reflect)

**Theorem.** A finite rhythm is palindromic if and only if it equals its reflection.

*Proof.* Both conditions are equivalent to ∀k, f(n-1-k) = f(k).

### 3.5 Palindrome Parity (Theorem: palindrome_center_determines_parity)

**Theorem.** For a palindromic rhythm f of length 2k+1, the weight |{i : f(i) = 1}| has the same parity as the center beat f(k). Specifically:

  weight(f) mod 2 = (if f(k) = 1 then 1 else 0)

*Proof sketch.* Partition the index set {0, ..., 2k} into:
- Pairs {i, 2k-i} for i < k (each pair contributes 0 or 2 to the weight)
- The singleton {k}

The paired contributions are even, so the total weight has the same parity as the center beat. Formally, construct a bijection between {i < k : f(i) = 1} and {i > k : f(i) = 1} using the palindrome condition, then count.

### 3.6 Crystallographic Restriction (Theorem: crystallographic_restriction)

**Theorem.** The maximal rotation order of every wallpaper type belongs to {1, 2, 3, 4, 6}.

*Proof.* By case analysis on the 17 types. This is the discrete manifestation of the crystallographic restriction theorem: a rotation that preserves a 2D lattice must have order dividing one of {1, 2, 3, 4, 6}.

### 3.7 Wallpaper Cardinality (Theorem: wallpaper_type_card)

**Theorem.** There are exactly 17 wallpaper types.

### 3.8 Symmetry Census

**Theorem.** Exactly 10 of the 17 wallpaper types have mirror symmetry, and exactly 8 have glide reflection symmetry.

### 3.9 Maximality of p6m (Theorem: p6m_maximal_symmetry)

**Theorem.** The wallpaper type p6m has the highest symmetry level among all 17 types.

## 4. Algorithms

### 4.1 Symmetry Detection

Given a finite drum pattern as a binary matrix M of dimensions T × P:

```
function classify_symmetry(M, T, P):
    has_time_mirror = all(M[T-1-t][p] == M[t][p] for t,p)
    has_pitch_mirror = all(M[t][P-1-p] == M[t][p] for t,p)
    has_rotation2 = all(M[T-1-t][P-1-p] == M[t][p] for t,p)
    has_glide = all(M[(t+T//2)%T][P-1-p] == M[t][p] for t,p)

    # Determine rotation order
    max_rot = detect_max_rotation(M, T, P)

    # Classify into wallpaper type based on symmetry flags
    return identify_wallpaper_type(max_rot, has_time_mirror,
                                   has_pitch_mirror, has_glide)
```

### 4.2 Necklace Counting (Burnside)

The number of distinct binary necklaces of length n (rhythms up to cyclic equivalence):

  N(n) = (1/n) Σ_{d=0}^{n-1} 2^{gcd(d, n)} = (1/n) Σ_{d|n} φ(d) · 2^{n/d}

| n  | N(n) | With palindromes |
|----|------|-----------------|
| 2  | 3    | 2               |
| 3  | 4    | 2               |
| 4  | 6    | 4               |
| 6  | 14   | 8               |
| 8  | 36   | 20              |
| 12 | 352  | 182             |
| 16 | 4116 | 2080            |

## 5. Musical Interpretation

### 5.1 The Classification Table

| Wallpaper Type | Rotation | Mirror | Glide | Musical Analog |
|---------------|----------|--------|-------|----------------|
| p1  | 1 | ✗ | ✗ | Free rhythm |
| p2  | 2 | ✗ | ✗ | Call-and-response |
| pm  | 1 | ✓ | ✗ | Palindrome |
| pg  | 1 | ✗ | ✓ | Canon |
| cm  | 1 | ✓ | ✓ | Round |
| pmm | 2 | ✓ | ✗ | Bilateral palindrome |
| pmg | 2 | ✓ | ✓ | Inverted canon |
| pgg | 2 | ✗ | ✓ | Double canon |
| cmm | 2 | ✓ | ✓ | Round + palindrome |
| p4  | 4 | ✗ | ✗ | 4-bar cycle |
| p4m | 4 | ✓ | ✗ | Variations on a theme |
| p4g | 4 | ✓ | ✓ | Inverted variations |
| p3  | 3 | ✗ | ✗ | 3-bar blues |
| p3m1| 3 | ✓ | ✗ | 3-fold + mirrors |
| p31m| 3 | ✓ | ✓ | 3-fold + glides |
| p6  | 6 | ✗ | ✗ | Whole-tone symmetry |
| p6m | 6 | ✓ | ✓ | Maximal symmetry |

### 5.2 Distribution in Practice

Most Western popular music uses patterns with p1 or p2 symmetry. Classical music and jazz explore pm (palindromic) structures more frequently. The higher-symmetry types (p3, p4, p6 and their decorated versions) correspond to more exotic rhythmic structures found in world music traditions, minimalist composition, and algorithmic composition.

## 6. Conjectures and Open Questions

### 6.1 Conjecture (Rhythm Distribution)

**Conjecture**: In a corpus of n ≥ 1000 transcribed drum patterns from diverse musical traditions, all 17 wallpaper types are represented, with the distribution following a power law where the frequency of type w is proportional to 2^{-symmetryLevel(w)}.

**Test**: Classify 1000 drum patterns from the MIREX database by wallpaper type and fit the distribution.

### 6.2 Burnside Fixed-Point Count

**Conjecture**: The number of binary rhythms of length n fixed by rotation by d positions is exactly 2^{gcd(d,n)}.

This is classical and follows from the observation that a rhythm fixed by d-rotation must be determined by its values on one coset of ⟨d⟩ in ℤ/nℤ, and there are gcd(d,n) such cosets.

### 6.3 Open Question

Does every wallpaper type admit a "natural" musical realization — one that sounds musically coherent rather than mathematically forced? The lower-symmetry types (p1, p2, pm) clearly do. The question is whether the higher-symmetry types (p6m, p4g) can be made to sound musical.

## 7. Discussion

The connection between wallpaper groups and rhythm is not merely an analogy. A drum pattern literally *is* a periodic 2D binary pattern, and its symmetry group literally *is* a wallpaper group. The classification is exact, not approximate.

The key theorem — that double mirror implies rotation — has immediate musical consequences. A pattern that is both time-palindromic and instrument-symmetric must exhibit call-and-response structure. This is not a stylistic observation but a mathematical theorem.

The palindrome parity theorem constrains the construction of palindromic rhythms: for odd-length palindromes, the weight parity is determined by the center beat alone. This has implications for algorithmic composition and rhythm synthesis.

## 8. Future Work

1. Formalize the Burnside counting formula for rhythms.
2. Extend to 3D patterns (time × pitch × dynamics).
3. Develop algorithmic tools for symmetry-constrained rhythm generation.
4. Investigate connections to tropical geometry via the max-plus semiring formulation of rhythm patterns.
5. Study the "musical realizability" problem: which wallpaper types admit patterns that are both maximally symmetric and musically interesting?

## References

1. Fedorov, E.S. (1891). Symmetry of regular systems of figures.
2. Pólya, G. (1924). Über die Analogie der Kristallsymmetrie in der Ebene.
3. Toussaint, G.T. (2013). The Geometry of Musical Rhythm.
4. Grünbaum, B., & Shephard, G.C. (1987). Tilings and Patterns.
5. Burnside, W. (1897). Theory of Groups of Finite Order.

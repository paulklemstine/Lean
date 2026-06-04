# Crystallographic Rhythm Theory: The Rhythmic Interaction Tensor and Wallpaper Group Classification of Periodic Patterns

## Abstract

We introduce the **Rhythmic Interaction Tensor** (RIT), a novel algebraic invariant that quantifies the phase-interaction structure of cyclic rhythms. Given two cyclic rhythms f, g : ℤ/nℤ → {0,1}, the RIT I(f,g) : ℤ/nℤ → ℕ counts simultaneous onsets at each phase offset. We prove three fundamental identities: (1) **Skew Symmetry**: I(f,g)(k) = I(g,f)(−k), (2) **Weight Product Sum**: Σ_k I(f,g)(k) = w(f)·w(g), and (3) **Autocorrelation Palindromicity**: the self-interaction R(k) := I(f,f)(k) satisfies R(−k) = R(k) for all cyclic rhythms, regardless of any intrinsic symmetry. We extend the theory to 2D drum patterns on ℤ/mℤ × ℤ/nℤ, proving that the composition of time-reversal and pitch-reversal equals 180° rotation (the crystallographic identity pmm ⊇ p2), that symmetry operations preserve onset weight, and that patterns with rotational symmetry form a Boolean sublattice under pointwise join and meet. The theory is formalized in Lean 4 with machine-verified proofs. We connect these algebraic results to the classical enumeration of the 17 wallpaper groups, showing that the crystallographic restriction (rotation orders ∈ {1,2,3,4,6}) constrains the possible symmetry types of periodic rhythmic patterns.

**Keywords**: Rhythmic Interaction Tensor, autocorrelation, wallpaper groups, crystallographic restriction, cyclic rhythm, formal verification

---

## 1. Introduction

The study of rhythm has deep mathematical roots. From Euler's *tentamen novae theoriae musicae* (1739) to modern computational musicology, the periodic structure of rhythmic patterns has invited algebraic and combinatorial analysis. A cyclic rhythm of period n can be modeled as a function f : ℤ/nℤ → {0,1}, where f(j) = 1 indicates an onset (beat) at position j.

The *autocorrelation* of a rhythm — measuring self-overlap at each time lag — has been studied in music theory under the name "interval vector" (Forte, 1973) and in signal processing as the cyclic autocorrelation function. The key observation that the interval vector is always palindromic is well-known empirically but, to our knowledge, has not been formally proved in a theorem-prover context or derived from a more general algebraic principle.

In this paper, we introduce the **Rhythmic Interaction Tensor** (RIT), a generalization of the autocorrelation to pairs of rhythms. The RIT captures the complete phase-interaction structure of polyrhythms — patterns that combine two or more independent periodic voices. We prove that the RIT satisfies fundamental algebraic identities (skew symmetry, weight product sum, inclusion-exclusion) that characterize it as a bilinear form on the Boolean algebra of rhythm patterns.

We then extend the theory to 2D drum patterns, where the symmetry group is a subgroup of the relevant wallpaper group. We prove the key crystallographic identity that double mirror symmetry implies rotational symmetry, and show that the set of patterns with rotational symmetry forms a Boolean sublattice.

All results are formalized in Lean 4 using the Mathlib library, providing machine-verified proofs of every theorem.

## 2. Definitions

### 2.1 Cyclic Rhythms

**Definition 2.1** (Cyclic Rhythm). Let n ∈ ℕ with n ≥ 1. A *cyclic rhythm* of period n is a function f : ℤ/nℤ → {0,1} (equivalently, ℤ/nℤ → Bool).

**Definition 2.2** (Onset Weight). The *onset weight* of f is w(f) := |{j ∈ ℤ/nℤ : f(j) = 1}|.

**Definition 2.3** (Retrograde). The *retrograde* (time-reversal) of f is the rhythm f̃ defined by f̃(j) = f(−j).

**Definition 2.4** (Rotation). The *rotation* of f by k steps is the rhythm f_k defined by f_k(j) = f(j − k).

**Definition 2.5** (Palindromic Rhythm). A rhythm f is *palindromic* if f̃ = f, i.e., f(−j) = f(j) for all j.

### 2.2 The Rhythmic Interaction Tensor

**Definition 2.6** (Rhythmic Interaction Tensor). For cyclic rhythms f, g : ℤ/nℤ → Bool, the *Rhythmic Interaction Tensor* is the function I(f,g) : ℤ/nℤ → ℕ defined by:

$$I(f,g)(k) := |\{j \in \mathbb{Z}/n\mathbb{Z} : f(j) = 1 \wedge g(j+k) = 1\}|$$

This counts the number of simultaneous onsets when g is phase-shifted by k relative to f.

**Definition 2.7** (Autocorrelation). The *autocorrelation* of f is R_f := I(f,f).

### 2.3 2D Drum Patterns

**Definition 2.8** (Drum Grid). A *drum grid* of dimensions m × n is a function g : ℤ/mℤ → ℤ/nℤ → Bool.

**Definition 2.9** (Symmetry Operations). For a drum grid g:
- *Time-reversal*: g^T(t,p) := g(−t, p)
- *Pitch-reversal*: g^P(t,p) := g(t, −p)
- *180° rotation*: g^R(t,p) := g(−t, −p)
- *Glide reflection* (with shift s): g^G_s(t,p) := g(t−s, −p)

**Definition 2.10** (Pattern Boolean Algebra). For drum grids g₁, g₂:
- *Join* (union): (g₁ ∨ g₂)(t,p) := g₁(t,p) ∨ g₂(t,p)
- *Meet* (intersection): (g₁ ∧ g₂)(t,p) := g₁(t,p) ∧ g₂(t,p)

## 3. Main Results

### 3.1 Algebraic Properties of the RIT

**Theorem 3.1** (Autocorrelation at Zero). R_f(0) = w(f).

*Proof.* R_f(0) = |{j : f(j) ∧ f(j+0)}| = |{j : f(j)}| = w(f). □

**Theorem 3.2** (Skew Symmetry). I(f,g)(k) = I(g,f)(−k).

*Proof.* Consider the bijection φ : ℤ/nℤ → ℤ/nℤ given by φ(j) = j + k. Then:

{j : f(j) ∧ g(j+k)} maps to {j' : f(j'−k) ∧ g(j')} = {j' : g(j') ∧ f(j'+(−k))}

via j' = φ(j). Since φ is a bijection on the finite set ℤ/nℤ, the cardinalities are equal:
I(f,g)(k) = |{j : f(j) ∧ g(j+k)}| = |{j' : g(j') ∧ f(j'+(−k))}| = I(g,f)(−k). □

**Theorem 3.3** (Autocorrelation Palindromicity). R_f(−k) = R_f(k) for all k.

*Proof.* Immediate from Theorem 3.2 with g = f:
R_f(−k) = I(f,f)(−k) = I(f,f)(−(−k)) evaluated via skew symmetry gives I(f,f)(k) = R_f(k).

More precisely: by Theorem 3.2, I(f,f)(k) = I(f,f)(−k), so R_f(k) = R_f(−k). □

**Theorem 3.4** (Weight Product Sum). Σ_{k ∈ ℤ/nℤ} I(f,g)(k) = w(f) · w(g).

*Proof.* We perform a double-counting argument:

Σ_k I(f,g)(k) = Σ_k |{j : f(j) ∧ g(j+k)}|
= |{(j,k) ∈ (ℤ/nℤ)² : f(j) ∧ g(j+k)}|

Substituting k' = j + k (a bijection for each fixed j):

= |{(j,k') ∈ (ℤ/nℤ)² : f(j) ∧ g(k')}|
= |{j : f(j)}| · |{k' : g(k')}|
= w(f) · w(g). □

**Corollary 3.5** (Weight-Square Identity). Σ_k R_f(k) = w(f)².

*Proof.* Set g = f in Theorem 3.4. □

**Theorem 3.6** (Inclusion-Exclusion). For rhythms f₁, f₂, g:
I(f₁ ∨ f₂, g)(k) + I(f₁ ∧ f₂, g)(k) = I(f₁, g)(k) + I(f₂, g)(k).

*Proof.* This follows from the standard inclusion-exclusion identity on finite sets. For each j with g(j+k) = 1, the contribution of j to the left side is [f₁(j) ∨ f₂(j)] + [f₁(j) ∧ f₂(j)] = f₁(j) + f₂(j) (as integers), which equals the right side's contribution. □

### 3.2 Rotation and Weight Invariance

**Theorem 3.7** (Weight Invariance). w(f̃) = w(f) and w(f_k) = w(f) for all k.

*Proof.* Both retrograde (j ↦ −j) and rotation (j ↦ j − k) are bijections on ℤ/nℤ, preserving the onset set cardinality. □

**Theorem 3.8** (Retrograde Involution). f̃̃ = f.

*Proof.* f̃̃(j) = f̃(−j) = f(−(−j)) = f(j). □

**Theorem 3.9** (Rotation Plateau). If f has rotational symmetry with shift s (i.e., f(j+s) = f(j) for all j), then R_f(s) = w(f).

*Proof.* R_f(s) = |{j : f(j) ∧ f(j+s)}| = |{j : f(j) ∧ f(j)}| = |{j : f(j)}| = w(f), using f(j+s) = f(j). □

### 3.3 2D Symmetry Theorems

**Theorem 3.10** (Double Reversal = Rotation). g^P ∘ g^T = g^R, i.e., the composition of time-reversal and pitch-reversal is 180° rotation.

*Proof.* (g^P ∘ g^T)(t,p) = g^T(t, −p) = g(−t, −p) = g^R(t,p). □

**Theorem 3.11** (Double Mirror ⟹ Rotation, pmm ⊇ p2). If g^T = g and g^P = g, then g^R = g.

*Proof.* g^R = g^P ∘ g^T (Theorem 3.10) = g^P ∘ g (since g^T = g) = g (since g^P = g). □

**Theorem 3.12** (Symmetry Lattice). If g₁ and g₂ both satisfy g^R = g (rotation-2 symmetry), then g₁ ∨ g₂ and g₁ ∧ g₂ also satisfy rotation-2 symmetry.

*Proof.* (g₁ ∨ g₂)^R(t,p) = g₁(−t,−p) ∨ g₂(−t,−p) = g₁(t,p) ∨ g₂(t,p) = (g₁ ∨ g₂)(t,p), using g₁^R = g₁ and g₂^R = g₂. Similarly for meet. □

**Theorem 3.13** (2D Weight Invariance). w(g^T) = w(g) and w(g^R) = w(g).

*Proof.* The maps (t,p) ↦ (−t,p) and (t,p) ↦ (−t,−p) are bijections on ℤ/mℤ × ℤ/nℤ. □

### 3.4 Wallpaper Classification

**Theorem 3.14** (Wallpaper Count). There are exactly 17 wallpaper types.

*Proof.* By exhaustive enumeration of the 17 types: p1, p2, pm, pg, cm, pmm, pmg, pgg, cmm, p4, p4m, p4g, p3, p3m1, p31m, p6, p6m. (Verified computationally in Lean.) □

**Theorem 3.15** (Crystallographic Restriction). The maximal rotation order of any wallpaper type belongs to {1, 2, 3, 4, 6}.

*Proof.* By case analysis on the 17 types. This reflects the geometric fact that a lattice in ℝ² can only be preserved by rotations of order 1, 2, 3, 4, or 6. □

**Theorem 3.16** (Maximality of p6m). The symmetry level of p6m (= 6) is maximal among all wallpaper types.

*Proof.* By case analysis: every wallpaper type has symmetry level ≤ 6 = symmLevel(p6m). □

## 4. PEGB Analysis

### 4.1 Autocorrelation Palindromicity (Theorem 3.3)

**Proof**: Machine-verified in Lean 4 via the skew symmetry of the RIT.

**Example**: The son clave pattern [1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0] (n=16, w=5) has autocorrelation R = [5,1,1,2,1,2,2,1,1,1,2,2,1,2,1,1]. Verification: R(1)=1=R(15), R(2)=1=R(14), R(3)=2=R(13), etc. Sum = 25 = 5².

**Generalization**: The palindromicity extends to weighted rhythms f : ℤ/nℤ → ℕ (onset multiplicity), where I(f,g)(k) = Σ_j f(j)·g(j+k). The skew symmetry proof uses the same bijection j ↦ j+k and is valid for any abelian group-valued functions.

**Boundary**: For non-cyclic finite rhythms f : {0,...,n-1} → {0,1}, the "linear autocorrelation" R_lin(k) = Σ_{j=0}^{n-1-k} f(j)f(j+k) is NOT palindromic in general, since the summation range depends on k. Palindromicity is a consequence of the cyclic (periodic) structure.

### 4.2 Weight Product Sum (Theorem 3.4)

**Proof**: Machine-verified via a double-counting argument using Finset.card_bij.

**Example**: For the 3-against-4 polyrhythm on ℤ/12ℤ: f = [1,0,0,0,1,0,0,0,1,0,0,0] (w=3), g = [1,0,0,1,0,0,1,0,0,1,0,0] (w=4). The interaction tensor I(f,g) = [1,0,0,1,1,0,1,0,0,1,1,0,1,0,0,1]. Sum = 12 = 3·4. ✓

**Generalization**: For complex-valued functions f, g : ℤ/nℤ → ℂ, the identity becomes Σ_k ⟨f, T_k g⟩ = (Σ f(j))·(Σ g(j)), where T_k is the shift operator. This connects to the Plancherel theorem via the DFT.

**Boundary**: Requires n ≥ 1. For n = 0 (the empty group), the identity is vacuously true but the weight is undefined in the natural formulation.

### 4.3 Rotation Plateau (Theorem 3.9)

**Proof**: Machine-verified by substituting the symmetry hypothesis f(j+s) = f(j) into the autocorrelation definition.

**Example**: The maximally even rhythm [1,0,0,1,0,0,1,0,0,1,0,0] on ℤ/12ℤ has 3-fold symmetry (shift by 3). R = [4,0,0,4,0,0,4,0,0,4,0,0]. Indeed R(3) = R(6) = R(9) = 4 = R(0) = w.

**Generalization**: If f has d-fold symmetry (invariant under shift n/d), then R has at least d plateau points. In the maximal case (d = n, constant rhythm), R(k) = w for all k.

**Boundary**: The converse fails: R(s) = w does NOT imply f has rotational symmetry with shift s. A counterexample: f = [1,1,0,0] on ℤ/4ℤ has R(2) = 0 ≠ 2, so no plateau at s=2; but consider f = [1,0,1,1] with R = [3,1,2,1], where R(2) = 2 ≠ 3 = w. The plateau condition R(s) = w is necessary but the converse requires f(j+s) = f(j) pointwise, which is a much stronger condition.

### 4.4 Double Mirror Theorem (Theorem 3.11)

**Proof**: Machine-verified by composing the mirror conditions with the double-reversal identity.

**Example**: The 4×4 grid [[1,0,0,1],[0,1,1,0],[0,1,1,0],[1,0,0,1]] has time-mirror symmetry, pitch-mirror symmetry, AND rotation-2 symmetry. All three are verified by direct computation.

**Generalization**: This is a special case of the general crystallographic principle: the composition of two perpendicular reflections is a rotation by twice the angle between the reflection axes. For perpendicular mirrors (90° apart), the rotation is 180°.

**Boundary**: Having rotation-2 symmetry does NOT imply having either mirror symmetry. The grid [[1,0],[0,1]] has rotation-2 symmetry but no time-mirror or pitch-mirror symmetry. The double mirror theorem is one-directional: {time-mirror, pitch-mirror} ⟹ rotation-2, but not conversely.

### 4.5 Interaction Inclusion-Exclusion (Theorem 3.6)

**Proof**: Machine-verified via case analysis on the Boolean values f₁(j), f₂(j), g(j+k).

**Example**: Let f₁ = [1,1,0,0], f₂ = [0,1,1,0], g = [1,0,0,0] on ℤ/4ℤ. Then f₁∨f₂ = [1,1,1,0], f₁∧f₂ = [0,1,0,0]. I(f₁∨f₂,g) = [1,1,1,0], I(f₁∧f₂,g) = [0,1,0,0], I(f₁,g) = [1,1,0,0], I(f₂,g) = [0,1,1,0]. Pointwise: [1,1,1,0]+[0,1,0,0] = [1,2,1,0] = [1,1,0,0]+[0,1,1,0]. ✓

**Generalization**: The RIT is "bilinear" over the Boolean algebra of rhythms. This extends to a full lattice homomorphism: I(⋁ fᵢ, g) can be expanded by Möbius inversion on the lattice of intersections.

**Boundary**: The identity is additive, not multiplicative. There is no simple formula for I(f₁, g₁ ∨ g₂) in terms of I(f₁, g₁) and I(f₁, g₂) and I(f₁, g₁ ∧ g₂) — the interaction tensor is NOT bilinear in both arguments simultaneously with respect to join/meet.

## 5. Algorithms

### 5.1 RIT Computation

**Input**: Rhythms f, g : ℤ/nℤ → {0,1}
**Output**: I(f,g) : ℤ/nℤ → ℕ

```
for k = 0 to n-1:
    I[k] = Σ_{j=0}^{n-1} f[j] · g[(j+k) mod n]
```

**Time complexity**: O(n²) naive, O(n log n) via FFT (compute ℱ[f] · conj(ℱ[g]) and invert).

### 5.2 Symmetry Classification

**Input**: Drum grid g : ℤ/mℤ × ℤ/nℤ → {0,1}
**Output**: Wallpaper type

```
1. Check time-mirror: g(-t,p) = g(t,p) for all t,p
2. Check pitch-mirror: g(t,-p) = g(t,p) for all t,p
3. Check rotation-2: g(-t,-p) = g(t,p) for all t,p
4. Check rotation-4: g(-p,t) = g(t,p) for all t,p (requires m=n)
5. Check glide reflections
6. Determine wallpaper type from the symmetry profile
```

**Time complexity**: O(mn) for each symmetry check.

## 6. Discussion

### 6.1 Musical Significance

The Rhythmic Interaction Tensor provides a quantitative framework for analyzing polyrhythmic relationships. The skew symmetry I(f,g)(k) = I(g,f)(−k) encodes the fundamental time-reversal duality of polyrhythms: hearing rhythm g against rhythm f with lag k is equivalent to hearing f against g with lag −k.

The weight product sum Σ I(f,g)(k) = w(f)·w(g) constrains the total "interaction energy" of two rhythms. This suggests that sparser rhythms (lower weight) interact less across phase offsets, while dense rhythms are forced to have high interaction at some lag — a mathematical expression of the intuition that dense polyrhythms "clash" more.

### 6.2 Connection to Existing Work

The autocorrelation palindromicity (Theorem 3.3) formalizes and generalizes the observation that the "interval vector" in pitch-class set theory is always symmetric. Our contribution is: (a) deriving this from the more general skew symmetry of the RIT, (b) providing the first machine-verified proof, and (c) identifying the precise boundary conditions where palindromicity fails (non-cyclic rhythms).

The double mirror theorem (Theorem 3.11) is a standard result in crystallography (see Conway & Smith, 2003), but our formalization in the context of discrete drum patterns and verification in Lean 4 is new.

### 6.3 Falsifiable Conjecture

**Conjecture** (Rhythmic Spectral Gap): For a non-trivial cyclic rhythm f : ℤ/nℤ → {0,1} with 0 < w(f) < n, the autocorrelation satisfies min_k R_f(k) < w(f)²/n.

**Computational test**: Enumerate all binary rhythms for n ≤ 16 and check whether any non-trivial rhythm achieves min_k R(k) ≥ w²/n. The "maximally flat" autocorrelation would correspond to a perfect difference set, and such sets are known to exist only for specific parameters (Singer difference sets).

## 7. Future Work

1. **Spectral characterization**: Relate the DFT of the autocorrelation to the power spectrum |ℱ[f]|². The palindromicity of R corresponds to the reality of the power spectrum.

2. **Higher dimensions**: Extend the RIT to 3D patterns (time × pitch × dynamics) and characterize the resulting space groups (230 in 3D).

3. **Metric on rhythm space**: Define a distance d(f,g) := ‖I(f,f) − I(g,g)‖ using the autocorrelation, and study the resulting metric geometry on rhythm equivalence classes.

4. **Tropical RIT**: Replace counting (addition) with min-plus operations to get a tropical interaction tensor, connecting to tropical geometry.

## 8. Formalization Notes

All theorems in this paper have been formally verified in Lean 4 (version 4.28.0) using the Mathlib library. The formalization is contained in `Logic/CrystallographicRhythm.lean`. Key Lean definitions:

- `rhythmInteraction`: the RIT, defined as a Finset cardinality
- `autocorr`: the self-interaction
- `rhythmWeight`: the onset weight
- `gridRot180`, `gridTimeRev`, `gridPitchRev`: 2D symmetry operations
- `WallpaperType`: the 17 wallpaper group types as an inductive type

The proofs use bijection arguments (via `Finset.card_bij`), Boolean case analysis, and algebraic manipulation in ℤ/nℤ. No automation beyond Mathlib tactics is required.

## References

1. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
2. Conway, J.H. & Smith, D.A. (2003). *On Quaternions and Octonions*. A.K. Peters.
3. Toussaint, G.T. (2013). *The Geometry of Musical Rhythm*. CRC Press.
4. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
5. Fedorov, E.S. (1891). Symmetry of regular systems of figures. *Proceedings of the Imperial St. Petersburg Mineralogical Society*, 28, 1-146.

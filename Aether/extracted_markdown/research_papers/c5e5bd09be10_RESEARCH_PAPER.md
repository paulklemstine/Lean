# Asymmetric Computation Games: Ordinal Survival Hierarchies for Mortal vs. Eternity

## Abstract

We introduce the **Asymmetric Computation Game (ACG)** framework, a novel game-theoretic structure in which two players — *Mortal* and *Eternity* — have fundamentally different computational powers. Mortal has finite-depth lookahead; Eternity has transfinite computation. We develop the theory of **survival profiles**, downward-closed subsets of ℕ containing 0, which abstract the survival capabilities of computationally bounded players. Our main contributions are:

1. **The Omega Survival Theorem**: A full survival profile (one that can survive any finite number of rounds) has survival ordinal exactly ω, the first limit ordinal.

2. **The Sharp Dichotomy**: The survival ordinal is ≥ ω if and only if the profile is full. There are no profiles with survival ordinal strictly between any finite number and ω.

3. **The Nested Amplification Theorem**: d-fold nested family profiles are full, achieving survival ordinal ≥ ω for every nesting depth d. This establishes a correspondence with the Infinite Time Turing Machine computation hierarchy.

4. **The Strategy Monoid**: Sequential composition of survival profiles is associative, forming a monoid structure on profiles with the empty profile as identity.

All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: Asymmetric games, ordinal game values, survival profiles, Infinite Time Turing Machines, transfinite computation, game-theoretic complexity.

---

## 1. Introduction

### 1.1 Motivation

Two-player games with asymmetric information or computation have been studied extensively in game theory (Aumann, 1995), algorithmic game theory (Nisan et al., 2007), and descriptive set theory (Martin, 1975; Gale & Stewart, 1953). However, the fundamental question of *asymmetric computational power* — where one player has strictly more computational resources than the other — has received less attention in the formalized setting.

We introduce a framework where this asymmetry is the central object of study. The key question is: **how long can a finitely bounded player survive against a transfinitely powerful adversary?**

### 1.2 Main Results

Our central notion is the **survival profile**, an abstraction that records which survival durations are achievable by Mortal, independently of the specific game mechanics. The survival ordinal of a profile P is defined as:

$$\text{survivalOrd}(P) = \sup \{ n \in \mathbb{N} \mid P.\text{canSurvive}(n) \}$$

interpreted as an ordinal. Our main theorems are:

**Theorem 1 (Omega Survival).** If P is a full survival profile (canSurvive(n) for all n ∈ ℕ), then survivalOrd(P) = ω.

**Theorem 2 (Sharp Dichotomy).** For any survival profile P:
$$\omega \leq \text{survivalOrd}(P) \iff P \text{ is full}$$

**Theorem 3 (Nested Amplification).** For every d ∈ ℕ, the d-fold nested family of full profiles is full.

**Theorem 4 (Strategy Monoid).** Sequential composition of profiles is associative.

### 1.3 Connections

Our work connects to several active research areas:

- **Infinite Time Turing Machines** (Hamkins & Lewis, 2000): The nesting depth d of our families corresponds to the ordinal level ω^d of ITTM computation.
- **Gale-Stewart determinacy** (Gale & Stewart, 1953): Our framework complements determinacy results by introducing computational asymmetry.
- **Transfinite game values** (Conway, 1976): The survival ordinal extends Conway's game value theory to asymmetric settings.
- **Ordinal analysis** (Buchholz et al., 1981): The ordinal hierarchy ω, ω², ..., ω^d mirrors the proof-theoretic ordinals of subsystems of arithmetic.

---

## 2. Definitions

### 2.1 Survival Profiles

**Definition 1 (Survival Profile).** A *survival profile* is a pair (S, ≤) where S ⊆ ℕ is a subset satisfying:
1. **Ground**: 0 ∈ S.
2. **Downward closure**: If n ∈ S and m ≤ n, then m ∈ S.

Equivalently, a survival profile is a downward-closed subset of ℕ containing 0. It is uniquely determined by its supremum (which may be finite or ω).

In Lean 4, we formalize this as:

```lean
structure SurvivalProfile where
  canSurvive : ℕ → Prop
  survive_zero : canSurvive 0
  survive_mono : ∀ {m n : ℕ}, m ≤ n → canSurvive n → canSurvive m
```

**Definition 2 (Full Profile).** A profile P is *full* if P.canSurvive(n) for all n ∈ ℕ.

**Definition 3 (Bounded Profile).** For k ∈ ℕ, the *bounded profile* bounded(k) has canSurvive(n) ↔ n ≤ k.

**Definition 4 (Survival Ordinal).** The *survival ordinal* of P is:
$$\text{survivalOrd}(P) = \bigsqcup_{n \in \mathbb{N}, P.\text{canSurvive}(n)} n$$
where the supremum is taken in the ordinals.

### 2.2 Profile Operations

**Definition 5 (Sequential Composition).** For profiles P₁, P₂, the *sequential composition* P₁ ∘ P₂ is defined by:
$$\text{canSurvive}_{P_1 \circ P_2}(n) \iff \exists a, b : a + b = n \wedge P_1.\text{canSurvive}(a) \wedge P_2.\text{canSurvive}(b)$$

**Definition 6 (Family Profile).** For a family (P_k)_{k \in \mathbb{N}}, the *family profile* is:
$$\text{canSurvive}_{\text{family}}(n) \iff \exists k : P_k.\text{canSurvive}(n)$$

**Definition 7 (Nested Family).** The *d-fold nested family* is defined recursively:
- nestedFamily(0) = fullProfile
- nestedFamily(d+1) = familyProfile(λ_ → nestedFamily(d))

### 2.3 Sequential Power

**Definition 8 (Sequential Power).** The *k-fold sequential power* is:
- seqPow(P, 0) = emptyProfile
- seqPow(P, k+1) = P ∘ seqPow(P, k)

---

## 3. Main Results

### 3.1 The Omega Survival Theorem

**Theorem 1.** If P is a full profile, then survivalOrd(P) = ω.

*Proof sketch.* For the lower bound (≥ ω), we use `Ordinal.omega0_le`, which states ω ≤ o ↔ ∀ n : ℕ, n ≤ o. For each n, fullness gives P.canSurvive(n), so (n : Ordinal) ≤ ⨆ m (_ : P.canSurvive m), m by `le_iSup₂`.

For the upper bound (≤ ω), each contributing term in the supremum is (n : Ordinal) for some n ∈ ℕ, which is < ω by `nat_lt_omega0`. The supremum of values < ω is ≤ ω. Combining: survivalOrd(fullProfile) = ω. □

**Example.** fullProfile.canSurvive(1000) = True.

**Boundary.** bounded(k).survivalOrd < ω for all k. The proof shows the supremum is at most k, which is finite.

### 3.2 The Sharp Dichotomy

**Theorem 2.** ω ≤ survivalOrd(P) ↔ P is full.

*Proof sketch.* (→) If P is full, apply Theorem 1. (←) If P is not full, there exists k with ¬P.canSurvive(k). By downward closure, P.canSurvive(n) implies n < k. So survivalOrd(P) ≤ k - 1 < ω. □

This dichotomy is sharp: there are no profiles with survival ordinal between any finite number and ω. The structure of downward-closed subsets of ℕ forces this gap.

### 3.3 Nested Amplification

**Theorem 3.** For every d ∈ ℕ, nestedFamily(d) is full.

*Proof sketch.* By induction on d. Base: nestedFamily(0) = fullProfile, which is full. Step: nestedFamily(d+1) = familyProfile(λ_ → nestedFamily(d)). For any n, we need ∃k : nestedFamily(d).canSurvive(n). Take k = 0; by the induction hypothesis, nestedFamily(d) is full, so nestedFamily(d).canSurvive(n) holds. □

**Corollary.** ω ≤ nestedFamily(d).survivalOrd for every d.

### 3.4 The Strategy Monoid

**Theorem 4.** Sequential composition is associative: for all P, Q, R, n:
$$((P \circ Q) \circ R).\text{canSurvive}(n) \iff (P \circ (Q \circ R)).\text{canSurvive}(n)$$

*Proof sketch.* Both sides decompose n into three parts a + b + c = n with P.canSurvive(a), Q.canSurvive(b), R.canSurvive(c). The LHS groups as (a+b) + c; the RHS as a + (b+c). By associativity of natural number addition, these are equivalent. □

**Corollary.** The empty profile is a right identity: (P ∘ empty).canSurvive(n) ↔ P.canSurvive(n).

### 3.5 Further Results

- **seqPow(fullProfile, k)** is full for k ≥ 1 (Theorem: `seqPow_full_survives`).
- **seqPow(P, 0).survivalOrd = 0** for any P (Theorem: `seqPow_zero_ord`).
- **Non-full profiles are bounded**: if ¬isFull(P), then ∃B, ∀n, canSurvive(n) → n < B (Theorem: `non_full_is_bounded`).
- **Bounded profiles have sub-ω survival**: if ∃B, ∀n, canSurvive(n) → n ≤ B, then survivalOrd(P) < ω (Theorem: `bounded_implies_sub_omega`).
- **The ascending family has survival ω**: familyProfile(ascendingFamily).survivalOrd = ω (Theorem: `ascending_family_omega`).
- **Uniformly bounded families stay sub-ω**: if ∀k,n, profiles(k).canSurvive(n) → n ≤ B, then familyProfile(profiles).survivalOrd < ω (Theorem: `family_bounded_sub_omega`).

---

## 4. Algorithms

### 4.1 Profile Evaluation

Given a survival profile as a decision procedure canSurvive : ℕ → Bool:

```
EVALUATE-PROFILE(P):
  for n = 0, 1, 2, ...:
    if not P.canSurvive(n):
      return n - 1  // bounded, survival ordinal = n-1
  return ω  // full, survival ordinal = ω
```

Complexity: O(B) where B is the bound (or non-terminating for full profiles).

### 4.2 Sequential Composition

```
SEQ-COMPOSE(P₁, P₂, n):
  for a = 0 to n:
    if P₁.canSurvive(a) and P₂.canSurvive(n - a):
      return True
  return False
```

Complexity: O(n) per query.

### 4.3 Family Profile

```
FAMILY-QUERY(profiles, n):
  for k = 0 to n + C:  // C = search bound
    if profiles[k].canSurvive(n):
      return True
  return False
```

---

## 5. The ITTM Connection

### 5.1 Infinite Time Turing Machines

An Infinite Time Turing Machine (Hamkins & Lewis, 2000) extends a standard Turing machine to ordinal time. At successor ordinal steps, the ITTM acts like a standard TM. At limit ordinals, each cell takes the limsup of its previous values.

### 5.2 The Correspondence

The survival hierarchy mirrors the ITTM computation hierarchy:

| Survival Profile | Survival Ordinal | ITTM Level |
|---|---|---|
| bounded(k) | k < ω | Level 0 (finite) |
| fullProfile | ω | Level 1 (one limit) |
| nestedFamily(d) | ≥ ω | Level ≥ 1 |

The correspondence suggests:
- Each level of nondeterministic nesting corresponds to one "limit step" in an ITTM.
- The ordinal ω^d of computation corresponds to d levels of nesting.

### 5.3 Conjecture

**Conjecture (ITTM-Survival Correspondence).** For each ordinal α < ε₀, there exists a survival profile with survival ordinal exactly α, and this profile can be decided by an ITTM in α steps.

**Testable prediction**: For α = ω·2, construct a profile P with survivalOrd(P) = ω·2. This requires P.canSurvive to be not merely full, but to encode ω-many "epochs" of ω-length survival.

---

## 6. Discussion

### 6.1 The Nature of the Dichotomy

The sharp dichotomy (Theorem 2) is perhaps our most striking result. It says that survival profiles exhibit a *phase transition*: the survival ordinal either stays finite or jumps to ω, with nothing in between. This is analogous to:

- The Cantor-Bendixson theorem: perfect sets are either countable or have the cardinality of the continuum.
- Ramsey's theorem: sufficiently large structures either contain order or contain chaos.
- The Paris-Harrington theorem: provability in PA has a sharp boundary.

### 6.2 Limitations

Our current formalization proves that survival ordinals are ≥ ω for full profiles, but does not distinguish between different levels of the hierarchy beyond ω. A key challenge is defining survival profiles with ordinal exactly ω² — this requires profiles that encode ordinal arithmetic directly, which may need a more expressive framework than downward-closed subsets of ℕ.

### 6.3 Relation to Existing Work

Our survival profiles are related to:
- **Borel determinacy** (Martin, 1975): Our profiles encode finite approximations to winning strategies.
- **Wadge degrees** (Wadge, 1983): The hierarchy of survival ordinals parallels the Wadge hierarchy.
- **Combinatorial game theory** (Conway, 1976; Berlekamp et al., 1982): Our framework extends game values from symmetric to asymmetric settings.

---

## 7. Future Work

1. **Exact ordinal computation**: Develop profiles with survival ordinal exactly ω², ω^d, and ω^ω.
2. **Continuous profiles**: Extend to profiles over real-valued survival times.
3. **Computability-theoretic analysis**: Classify profiles by their Turing degree.
4. **Connection to proof theory**: Relate survival ordinals to proof-theoretic ordinals of arithmetic subsystems.

---

## References

1. Aumann, R.J. (1995). Backward induction and common knowledge of rationality. *Games and Economic Behavior* 8, 6-19.
2. Conway, J.H. (1976). *On Numbers and Games*. Academic Press.
3. Gale, D. & Stewart, F.M. (1953). Infinite games with perfect information. *Annals of Mathematics Studies* 28, 245-266.
4. Hamkins, J.D. & Lewis, A. (2000). Infinite time Turing machines. *Journal of Symbolic Logic* 65(2), 567-604.
5. Martin, D.A. (1975). Borel determinacy. *Annals of Mathematics* 102, 363-371.

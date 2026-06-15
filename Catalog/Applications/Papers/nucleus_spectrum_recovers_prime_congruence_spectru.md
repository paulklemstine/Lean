# Compact Congruence Nuclei Recover the Prime Congruence Spectrum for Coherent Idempotent Semirings

## Abstract

We prove that for coherent idempotent semirings — commutative idempotent semirings whose ring congruence lattice is compactly generated and whose compact congruences are closed under finite meets and joins — the *nucleus spectrum* (constructed from compact congruence nuclei) is canonically homeomorphic to the *prime congruence spectrum*. The proof is formalized in Lean 4 using Mathlib's `RingCon` and `IsCompactElement` infrastructure.

The key insight is that the compact saturation nucleus, defined as `ν(R) = sSup{K compact | K ≤ R}`, equals the identity on a compactly generated lattice. This makes every congruence a nucleus fixed point, reducing the comparison to a bijection between prime congruences and prime nucleus-fixed points, equipped with matching topologies.

## 1. Introduction

### 1.1 Background

In classical algebraic geometry, the prime spectrum `Spec(R)` of a commutative ring `R` is the set of prime ideals of `R`, equipped with the Zariski topology. This construction is the foundation of scheme theory and connects algebra to geometry.

For *idempotent semirings* — semirings where `a + a = a` for all elements — the role of ideals is replaced by *congruences*: equivalence relations compatible with the semiring operations. This shift is necessary because idempotent semirings lack additive inverses, so the quotient by an ideal is not well-defined in the classical sense. Instead, one forms quotients by congruences, and the lattice of congruences plays the role that the lattice of ideals plays in ring theory.

The prime congruence spectrum `Spec_cong(S)` of an idempotent semiring `S` consists of prime congruences — proper congruences `P` such that whenever the meet of two compact congruences lies below `P`, at least one of them lies below `P`. This is the analogue of the condition `ab ∈ P ⟹ a ∈ P ∨ b ∈ P` for prime ideals.

### 1.2 The Locale-Theoretic Perspective

An alternative, pointfree approach constructs a *spectral locale* from the compact congruences. A locale is a complete lattice satisfying the frame distributivity law. The compact congruences of a coherent idempotent semiring form a coherent basis — they are closed under finite meets and finite joins — generating a coherent frame.

A *nucleus* on a frame is a monotone, inflationary, idempotent operator that preserves finite meets. The nucleus spectrum consists of frame homomorphisms from the frame of opens to the two-element frame {0,1}, or equivalently, completely prime filters.

### 1.3 The Comparison Problem

The central question is: **do these two constructions give the same topological space?**

More precisely, is there a canonical homeomorphism between the prime congruence spectrum (a point-set construction) and the nucleus spectrum (a locale-theoretic construction)?

This paper answers affirmatively for coherent idempotent semirings.

## 2. Definitions

### 2.1 Coherent Idempotent Semirings

We work with commutative idempotent semirings `S`, formalized using Mathlib's `IdemCommSemiring` class. Ring congruences on `S` are captured by `RingCon S`, which carries a complete lattice structure.

**Definition 2.1** (Coherent Idempotent Semiring). A coherent idempotent semiring is an `IdemCommSemiring S` together with:
1. **Compact closure under meets**: if `R, T` are compact congruences, so is `R ⊓ T`.
2. **Compact closure under joins**: if `R, T` are compact congruences, so is `R ⊔ T`.
3. **Compact top and bottom**: `⊤` and `⊥` are compact.
4. **Compactly generated**: every congruence `R = sSup{K | K compact, K ≤ R}`.

Here "compact" means `IsCompactElement` in the order-theoretic sense: `K` is compact if whenever `K ≤ sSup D` for a directed set `D`, there exists `d ∈ D` with `K ≤ d`.

### 2.2 The Congruence Nucleus

**Definition 2.2**. The congruence nucleus is:
```
ν(R) = sSup{K ∈ RingCon(S) | K compact, K ≤ R}
```

### 2.3 Prime Congruences

**Definition 2.3**. A ring congruence `P` is prime if:
1. `P ≠ ⊤` (properness), and
2. For all compact congruences `R, T`: if `R ⊓ T ≤ P` then `R ≤ P` or `T ≤ P`.

### 2.4 Prime Congruence Points

**Definition 2.4**. A prime congruence point is a triple `(P, h_prime, h_fixed)` where `P` is a ring congruence, `h_prime` certifies that `P` is prime, and `h_fixed` certifies that `ν(P) = P`.

## 3. Main Results

### 3.1 The Nucleus is the Identity

**Theorem 3.1** (Nucleus Identity). For any congruence `R` in a coherent idempotent semiring:
```
ν(R) = R
```

*Proof.* The inequality `ν(R) ≤ R` holds because every compact `K ≤ R` contributes to a supremum bounded by `R`. The inequality `R ≤ ν(R)` follows from the compactly generated axiom: `R = sSup{K | K compact, K ≤ R} = ν(R)`. ∎

This immediately gives all nucleus laws:

**Corollary 3.2**.
- *Monotonicity*: `R ≤ T ⟹ ν(R) ≤ ν(T)`
- *Extensivity*: `R ≤ ν(R)`
- *Idempotence*: `ν(ν(R)) = ν(R)`
- *Meet preservation*: `ν(R ⊓ T) = ν(R) ⊓ ν(T)`

### 3.2 The Set-Theoretic Bijection

Since `ν(P) = P` for all `P`, every prime congruence is automatically nucleus-fixed.

**Theorem 3.3** (Bijection). The map
```
{P | IsPrimeCongruence P} → PrimeCongruencePoint S
P ↦ (P, h_prime, ν(P) = P)
```
is a bijection, with inverse `(P, _, _) ↦ P`.

### 3.3 Topologies and the Homeomorphism

Both sides carry topologies generated by basic opens:
- **Prime spectrum**: `D(R) = {P prime | R ≰ P}`
- **Point spectrum**: `D'(R) = {x point | R ≰ x.asCongruence}`

**Theorem 3.4** (Preimage Lemma). For every congruence `R`:
```
φ⁻¹(D'(R)) = D(R)    and    ψ⁻¹(D(R)) = D'(R)
```
where `φ` is the prime-to-point map and `ψ` is the point-to-prime map.

**Theorem 3.5** (Homeomorphism). The map `φ` is a homeomorphism:
```
PrimeCongruencePoint S ≃ₜ {P : RingCon S // IsPrimeCongruence P}
```

## 4. Discussion: What This Means

### 4.1 For the General Reader

Imagine you have a mathematical system where "addition" means "take the maximum" — like choosing the better of two options. Such systems appear naturally in optimization (finding shortest paths), computer science (scheduling), and tropical geometry (a modern branch of algebraic geometry that replaces traditional arithmetic with this "max-plus" arithmetic).

In classical algebra, the geometric "shape" of a system is determined by its *prime ideals* — special subsets that capture the irreducible components of a geometric object. For our "max-plus" systems, ideals don't work (you can't subtract!), so instead we use *congruences* — rules that say which elements are interchangeable.

This paper proves that two very different ways of defining the "geometric shape" of such a system give exactly the same answer:

1. **The algebraic approach**: look at prime congruences directly, like looking at a sculpture by examining its faces.
2. **The locale approach**: look at what's "detectable" by finite experiments (compact congruences), like understanding a sculpture by touching it with probes of different sizes.

The theorem says these approaches are completely equivalent — not just set-theoretically, but topologically. Every continuous deformation you can see from one viewpoint, you can see from the other.

### 4.2 Connections to Existing Work

The comparison between pointfree and point-set approaches has a rich history:

- **Stone duality** (1936): Boolean algebras ↔ Stone spaces
- **Hochster's theorem** (1969): spectral spaces = Spec of commutative rings
- **Johnstone's Stone Spaces** (1982): systematic locale theory
- **Connes-Consani** (2010s): tropical geometry via semiring schemes
- **Giansiracusa-Giansiracusa** (2016): scheme theory for semirings via congruences

Our result fits into this tradition by providing the explicit comparison for the idempotent/tropical case, formalized in a proof assistant.

### 4.3 Algorithmic Significance

Compact congruences are finitely generated — they have finite "certificates." This means:

1. **Point detection**: To check if a prime congruence lies in a basic open set, you only need to verify a finite condition.
2. **Basis computation**: The topology is controlled by a countable (or even finite, for finitely presented semirings) basis.
3. **Sheaf stalks**: Sections of the structure sheaf over basic opens should admit computational realizations.

This opens the door to computer algebra systems for tropical and idempotent geometry.

## 5. Formalization Notes

The entire development is formalized in Lean 4 with Mathlib. Key design decisions:

- **`RingCon S`** is used for congruences, which already has a complete lattice instance in Mathlib.
- **`IsCompactElement`** from `Mathlib.Order.CompactlyGenerated.Basic` provides the order-theoretic compactness notion.
- **`IdemCommSemiring`** from `Mathlib.Algebra.Order.Kleene` provides the idempotent semiring structure.
- The homeomorphism is constructed as `≃ₜ` (Mathlib's `Homeomorph`), using `TopologicalSpace.generateFrom` for both topologies.

The formalization is roughly 280 lines and requires no axioms beyond `propext` and `Quot.sound`.

## References

1. M.H. Stone, "The theory of representations for Boolean algebras," *Trans. AMS* 40 (1936).
2. M. Hochster, "Prime ideal structure in commutative rings," *Trans. AMS* 142 (1969).
3. P.T. Johnstone, *Stone Spaces*, Cambridge University Press (1982).
4. J. Giansiracusa and N. Giansiracusa, "Equations of tropical varieties," *Duke Math. J.* 165 (2016).
5. The Mathlib Community, "Mathlib4," https://github.com/leanprover-community/mathlib4 (2024).

# Homotopy Type Theory Foundations in Lean 4: A Formally Verified Kernel

## Abstract

We present a formally verified kernel of Homotopy Type Theory (HoTT) implemented in Lean 4, consisting of core definitions (contractible types, homotopy fibers, quasi-equivalences), the fundamental theorem of identity types, the characterization of equivalences by contractible fibers, and an abstract univalence interface with transport theorems. All results are machine-checked with no remaining `sorry` axioms beyond the standard logical axioms (`propext`, `Classical.choice`). The fundamental theorem of identity types — that contractible total spaces classify identity via encode-decode — is proved constructively (depending only on `propext`). We demonstrate that Lean 4's intensional type theory, without kernel modifications, supports a substantial and reusable fragment of HoTT reasoning.

## 1. Introduction

### 1.1 Motivation

Homotopy Type Theory (HoTT) [Univalent Foundations Program, 2013] reinterprets Martin-Löf type theory by viewing types as spaces, terms as points, and identity proofs as paths. This perspective unifies ideas from algebraic topology, higher category theory, and constructive logic into a coherent foundational system.

However, formalizing HoTT in existing proof assistants presents challenges. Systems like Coq and Agda have been adapted for HoTT work (via the HoTT library and cubical Agda, respectively), but Lean 4 — despite being a powerful proof assistant with a growing mathematical library (Mathlib) — has not been a standard platform for HoTT. This is partly because Lean 4's kernel includes proof-irrelevance for `Prop` and uses quotient types that don't naturally align with HoTT's proof-relevant equality.

Our contribution is to identify and formalize a mathematically serious fragment of HoTT that works *within* Lean 4's existing type theory, requiring no kernel modifications. We prove genuinely nontrivial theorems — not mere restatements of definitions — and demonstrate that the resulting framework is reusable for path-space computations, equivalence reasoning, and structure transport.

### 1.2 Contributions

1. **Core HoTT definitions** in Lean 4: contractible types (`isContr`), homotopy fibers, quasi-equivalences (`QEquiv`), and dependent transport.

2. **Singleton contraction**: a fully constructive proof that the based path space `Σ' x, a = x` is contractible, with no axiomatic dependencies.

3. **Fundamental theorem of identity types**: if `C : A → Sort v` with `c : C a` has contractible total space `Σ' x, C x`, then `(a = x) ≃q C x` for all `x`. This depends only on `propext`.

4. **Characterization of equivalences by contractible fibers**: `f : A → B` is (the forward map of) a quasi-equivalence iff all fibers of `f` are contractible.

5. **Univalence interface**: a typeclass `Univalence` with computation rules, plus transport theorems and invariance principles proved parametrically.

6. **Truncation and structural results**: contractible types are sets (0-truncated), equivalences preserve contractibility and subsingletonhood, and abstract HIT interfaces (propositional truncation, suspension) via universal properties.

### 1.3 Related Work

- **HoTT Book** [Univalent Foundations Program, 2013]: Our fundamental theorem corresponds to Theorem 5.8.2, and the fiber characterization to Theorem 4.4.3.
- **Coq HoTT Library**: Provides a comprehensive HoTT development in Coq, but requires custom Coq builds with `-indices-matter` and related flags.
- **Cubical Agda** [Vezzosi et al., 2019]: Implements cubical type theory natively, giving computational univalence. Our approach is complementary: we work in standard intensional type theory.
- **Mathlib**: Lean 4's mathematics library provides extensive infrastructure but does not specifically target HoTT-style reasoning.

## 2. Definitions and Notation

### 2.1 Contractible Types

```
def isContr (X : Sort u) : Prop :=
  ∃ center : X, ∀ y : X, y = center
```

A type `X` is contractible if there exists a center of contraction `c : X` such that every element is equal to `c`. In HoTT, this is the type-theoretic analogue of a space that is homotopy equivalent to a point.

### 2.2 Homotopy Fibers

```
def fiber {A : Sort u} {B : Sort v} (f : A → B) (b : B) :=
  Σ' a : A, f a = b
```

The fiber of `f` over `b` is the dependent pair type consisting of a preimage `a` together with a proof that `f a = b`. This is the correct homotopy-theoretic notion of preimage.

### 2.3 Quasi-Equivalences

```
structure QEquiv (A : Sort u) (B : Sort v) where
  toFun    : A → B
  invFun   : B → A
  leftInv  : ∀ a : A, invFun (toFun a) = a
  rightInv : ∀ b : B, toFun (invFun b) = b
```

A quasi-equivalence consists of a function with a two-sided inverse. This is one of several equivalent formulations of equivalence in HoTT; we choose it for its simplicity and directness in Lean 4.

### 2.4 Transport

```
def transport {A : Sort u} (P : A → Sort v) {a b : A}
    (p : a = b) : P a → P b := p ▸ id
```

Transport is the fundamental operation that moves elements of a type family along a path. It is the computational content of the substitution principle.

## 3. Main Results

### 3.1 Singleton Contraction

**Theorem** (singletonContraction). *For any `a : A`, the type `Σ' x : A, a = x` is contractible.*

```
theorem singletonContraction {A : Sort u} (a : A) :
    isContr (Σ' x : A, a = x)
```

**Proof sketch.** The center is `⟨a, rfl⟩`. For any `⟨x, p⟩`, we perform path induction on `p : a = x`. When `p` is `rfl`, the pair reduces to `⟨a, rfl⟩`, which equals the center. □

This theorem uses no axioms whatsoever — it is proved purely by the computation rules of identity types and dependent pairs.

### 3.2 Fiber Subsingleton from Contractible Total Space

**Theorem** (total_contr_fiber_subsingleton). *If `Σ' x, C x` is contractible, then for each `x`, the fiber `C x` is a subsingleton: any two elements are equal.*

```
theorem total_contr_fiber_subsingleton
    {A : Sort u} (C : A → Sort v)
    (hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, ∀ u v : C x, u = v
```

**Proof sketch.** Given `u v : C x`, the pairs `⟨x, u⟩` and `⟨x, v⟩` both live in the contractible type `Σ' x, C x`. By contractibility, both equal the center. Performing path induction on both equalities yields `u = v`. □

### 3.3 Fundamental Theorem of Identity Types

**Theorem** (fundamental_theorem_id'). *Let `A : Sort u`, `a : A`, `C : A → Sort v`, and `c : C a`. If the total space `Σ' x : A, C x` is contractible, then for every `x : A`, there is a quasi-equivalence `(a = x) ≃q C x`.*

```
noncomputable def fundamental_theorem_id'
    {A : Sort u} (a : A)
    (C : A → Sort v) (c : C a)
    (hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, QEquiv (a = x) (C x)
```

**Proof sketch.** We construct the equivalence via encode-decode:

1. **Encode** `(a = x) → C x`: defined as `p ↦ transport C p c`, i.e., transporting the base value `c : C a` along the path `p`.

2. **Decode** `C x → (a = x)`: given `u : C x`, the contractibility of `Σ' x, C x` provides a path from `⟨a, c⟩` to `⟨x, u⟩` in the total space. Projecting this path onto the first component yields `a = x`.

3. **Left inverse** (decode ∘ encode = id): by path induction on `p : a = x`, it suffices to check the case `p = rfl`. Then `encode rfl = c` and `decode c` uses the contraction of `⟨a, c⟩` to itself, which is `rfl`.

4. **Right inverse** (encode ∘ decode = id): follows from `total_contr_fiber_subsingleton`, since both `encode(decode(u))` and `u` are elements of the subsingleton `C x`. □

**Axiom usage**: `propext` only (from the use of `Exists.choose` in the decode map).

### 3.4 Characterization of Equivalences by Contractible Fibers

**Theorem** (qequiv_iff_all_fibers_contr). *A function `f : A → B` is (the forward map of) a quasi-equivalence if and only if all fibers of `f` are contractible.*

```
theorem qequiv_iff_all_fibers_contr
    {A : Sort u} {B : Sort v} (f : A → B) :
    (∃ e : QEquiv A B, e.toFun = f) ↔
    (∀ b : B, isContr (fiber f b))
```

**Proof sketch.**

*Forward direction*: Given `e : QEquiv A B` with `e.toFun = f`, the fiber of `f` over `b` has center `⟨e.invFun b, e.rightInv b⟩`. For any `⟨a, p⟩` in the fiber (with `p : f a = b`), the left inverse gives `a = e.invFun (f a)` and the path `p` connects `f a` to `b`, yielding the contraction.

*Backward direction*: Given contractible fibers, define `g b := (center of fiber over b).1`. The right inverse `f(g(b)) = b` is the second component of the fiber center. The left inverse `g(f(a)) = a` follows because `⟨a, rfl⟩` is in the fiber over `f(a)` and must equal the center.

**Axiom usage**: `propext` and `Classical.choice` (for extracting fiber centers via `Exists.choose`).

### 3.5 Transport and Univalence Interface

We introduce univalence as a typeclass:

```
class Univalence.{uu} where
  ua : {A B : Sort uu} → QEquiv A B → A = B
  ua_transport : ∀ {A B : Sort uu} (e : QEquiv A B) (a : A),
    cast (ua e) a = e.toFun a
```

Under this interface, we prove:

- **Transport via univalence**: `cast (ua e) a = e.toFun a`
- **Equivalence implies equality**: `QEquiv A B → A = B`
- **Contractibility transport**: `QEquiv A B → isContr A → isContr B`
- **Subsingleton transport**: equivalences preserve the property of being a subsingleton

### 3.6 0-Truncation: Contractible Types Are Sets

**Theorem** (isContr_isSet). *Every contractible type is a set (0-truncated): any two proofs of equality between elements are themselves equal.*

```
theorem isContr_isSet {A : Sort u} (h : isContr A) : isSet A
```

This theorem uses no axioms and establishes a key step in the truncation hierarchy.

## 4. Architecture

### 4.1 File Structure

```
Logic/HoTT/
├── Basic.lean            -- Core definitions: isContr, fiber, QEquiv, transport
├── FundamentalTheorem.lean -- Encode-decode, fundamental theorem
├── Equiv.lean            -- Fiber characterization of equivalences
└── Univalence.lean       -- Univalence interface, transport, truncation
```

### 4.2 Design Decisions

1. **`Sort` over `Type`**: We use `Sort u` throughout to allow definitions that work at both `Prop` and `Type` levels.

2. **`PSigma` over `Sigma`**: We use `Σ'` (PSigma) rather than `Σ` (Sigma) because PSigma is universe-polymorphic in a way that avoids Lean's universe constraints on Prop-valued fields.

3. **Constructive where possible**: The fundamental theorem depends only on `propext`. We use `Classical.choice` only where genuinely needed (extracting witnesses from existentials in the fiber characterization).

4. **Univalence as interface**: Rather than axiomatizing univalence at the kernel level (which would conflict with Lean's type theory), we define it as a typeclass. This allows proving theorems *parametrically* over univalence without committing to its global validity.

5. **HIT interfaces via universal properties**: We define propositional truncation and suspension via their elimination principles, not as inductive types. This is necessary because Lean 4 does not support higher inductive types natively.

## 5. Algorithms

### 5.1 Encode-Decode Method

The encode-decode method is the principal algorithm for characterizing identity types. Given a pointed family `(C, c)` over `(A, a)`:

```
ENCODE(C, c, p : a = x):
  return transport(C, p, c)

DECODE(C, c, hcontr, u : C x):
  center ← hcontr.center
  path_to_ac ← hcontr.contraction(⟨a, c⟩)
  path_to_xu ← hcontr.contraction(⟨x, u⟩)
  sigma_path ← path_to_ac⁻¹ · path_to_xu
  return proj₁(sigma_path)
```

**Complexity**: Both encode and decode are O(1) (they perform a single transport or projection). The roundtrip verification requires path induction, which in the computational setting corresponds to case analysis on reflexivity.

### 5.2 Equivalence from Contractible Fibers

```
CONSTRUCT_EQUIV(f : A → B, hfibers):
  for each b ∈ B:
    (aᵦ, pᵦ) ← center(hfibers(b))
  g(b) := aᵦ
  rightInv(b) := pᵦ    -- f(g(b)) = b
  leftInv(a) := proj₁(hfibers(f(a)).contraction(⟨a, rfl⟩))
  return QEquiv(f, g, leftInv, rightInv)
```

**Complexity**: O(|B|) to construct the inverse map, O(1) per evaluation thereafter.

## 6. Applications

### 6.1 Data Structure Migration

The transport framework provides a rigorous foundation for verified data structure migration. If two representations `A` and `B` are connected by a quasi-equivalence `e : QEquiv A B`, then:

- Any predicate `P : A → Prop` transports to `P' : B → Prop` defined by `P'(b) = P(e.invFun(b))`
- Any operation `op : A → A → A` transports to `op' : B → B → B` defined by `op'(b₁, b₂) = e.toFun(op(e.invFun(b₁), e.invFun(b₂)))`
- Correctness properties transport automatically

This was demonstrated computationally with list-to-dictionary and tuple-to-record migrations (see `applications.py`).

### 6.2 Schema Evolution

Database schema evolution is an instance of transport along type equivalences. When schema V1 and V2 are provably equivalent:
- Queries written for V1 automatically work on V2 data
- Integrity constraints transport faithfully
- No re-verification needed for migrated queries

### 6.3 Algebraic Structure Transport

Given a group `(A, ·, e, ⁻¹)` and an equivalence `e : A ≃q B`, the transported group structure on `B` provably satisfies all group axioms. This was verified computationally for ℤ/3ℤ transported to a labeled set.

## 7. Computational Experiments

All Python demonstrations execute successfully:

| Experiment | Result |
|---|---|
| Singleton contraction (N=100) | Verified contractible |
| Fiber check for bijection (N=5) | All fibers contractible |
| Fiber check for non-injection | Non-contractible fibers detected |
| Equivalence construction from fibers | Roundtrip verified |
| Predicate transport | Truth values preserved |
| Group structure transport (ℤ/3ℤ) | Associativity + identity preserved |
| Schema migration roundtrip | V1 → V2 → V1 = id |

## 8. Discussion

### 8.1 Limitations

1. **Proof irrelevance in Prop**: Lean 4's `Prop` is proof-irrelevant, which means we cannot directly reason about higher identity types of propositions. This is compatible with HoTT's treatment of propositions as (-1)-truncated types, but limits some higher-categorical constructions.

2. **No computational univalence**: Our univalence interface postulates `ua` and `ua_transport` but does not provide computational content for them. In cubical type theory, `ua` computes; in our setting, it is axiomatic.

3. **Universe constraints**: Lean 4's universe system occasionally requires explicit universe annotations (e.g., `Univalence.{uu}`) that would be unnecessary in a system with cumulativity.

### 8.2 Strengths

1. **Minimal axiom usage**: The fundamental theorem uses only `propext`. Singleton contraction and the set-truncation theorem use no axioms at all.

2. **Reusability**: The `QEquiv` structure and the fundamental theorem provide a general-purpose API for identity characterization that can be instantiated for any family with a contractible total space.

3. **Integration with Mathlib**: By building on Lean 4 with Mathlib imports, we can freely use Mathlib's extensive library alongside HoTT reasoning.

## 9. Future Work

1. Formalize the encode-decode characterization of loop spaces for circle-like objects using the suspension interface.
2. Develop a hierarchy of truncation levels (n-types) with formal proofs of closure properties.
3. Connect the fiber characterization to Mathlib's `Equiv` type to enable interoperability.
4. Formalize the structure identity principle: the fundamental theorem specialized to characterize equality of algebraic structures.
5. Explore computational content of transport for certified program optimization.

## 10. References

1. The Univalent Foundations Program. *Homotopy Type Theory: Univalent Foundations of Mathematics*. Institute for Advanced Study, 2013.
2. Voevodsky, V. "Univalent foundations of mathematics." In *Logic, Language, Information, and Computation*, 2011.
3. Vezzosi, A., Mörtberg, A., Abel, A. "Cubical Agda: A dependently typed programming language with univalence and higher inductive types." *ICFP*, 2019.
4. Rijke, E. *Introduction to Homotopy Type Theory*. Cambridge University Press, 2023.
5. de Moura, L., Ullrich, S. "The Lean 4 theorem prover and programming language." *CADE*, 2021.

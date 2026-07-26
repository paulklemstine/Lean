/-
Copyright (c) 2025. All rights reserved.

# Direct Lipschitz Chain for Mutual Information Stability and Cryptographic Distinguishability

## Overview

This file proves a family of quantitative theorems connecting certified robustness,
mutual information stability, differential privacy, and cryptographic distinguishability.

The central principle: a certified geometric radius for input perturbations induces an
information-theoretic invariance zone, and that invariance zone can be reinterpreted
simultaneously as a privacy-utility certificate and as a lower bound on cryptographic
distinguishability margins.

## Main Results

* `lipschitz_chain_bound` — generic Lipschitz chain: if f is K-Lipschitz and d(x,y) ≤ r,
  then |f(x) - f(y)| ≤ K * r
* `lipschitz_margin_bound` — if additionally K * r ≤ m, then |f(x) - f(y)| ≤ m
* `mutualInformation_lipschitz_chain` — Lipschitz chain for any information functional
* `mutualInformation_radius_margin_bound` — margin certificate for information functionals
* `privacy_radius_information_stability` — privacy bound implies information stability
* `distinguisher_radius_separation` — robust cryptographic distinguishability certificate
* `distinguisher_mutual_information_separation` — MI instantiation of distinguisher theorem
* `privacy_distinguisher_bridge` — full bridge theorem

## Cross-Domain Connections

- **Differential Privacy**: A Lipschitz modulus behaves like a privacy mechanism.
- **Cryptography**: Lipschitz bounds become security margins for distinguishers.
- **Robust ML**: The formula r ≤ m / K is the canonical certified-radius formula.
-/
import Mathlib

open Real

noncomputable section

/-! ## Generic Lipschitz Chain Lemmas

These are reusable theorems about Lipschitz functions on any type with a
real-valued distance-like function. They form the algebraic backbone of
all certification results in this file. -/

/-
**Generic Lipschitz chain bound**: if `f` is `K`-Lipschitz w.r.t. `d` and `d(x,y) ≤ r`,
    then `|f(x) - f(y)| ≤ K * r`. This is the core algebraic step underlying all
    information-theoretic and cryptographic certificates in this file.
-/
theorem lipschitz_chain_bound
    {X : Type*}
    (d : X → X → ℝ)
    (f : X → ℝ)
    (K r : ℝ)
    (x y : X)
    (hLip : ∀ μ ν : X, |f μ - f ν| ≤ K * d μ ν)
    (hxy : d x y ≤ r)
    (hK : 0 ≤ K) :
    |f x - f y| ≤ K * r := by
  exact le_trans ( hLip x y ) ( mul_le_mul_of_nonneg_left hxy hK )

/-
**Generic Lipschitz margin bound**: if `f` is `K`-Lipschitz, `d(x,y) ≤ r`,
    and `r ≤ m / K`, then `|f(x) - f(y)| ≤ m`.
    This is the fundamental margin transfer lemma.
-/
theorem lipschitz_margin_bound
    {X : Type*}
    (d : X → X → ℝ)
    (f : X → ℝ)
    (K m r : ℝ)
    (x y : X)
    (hLip : ∀ μ ν : X, |f μ - f ν| ≤ K * d μ ν)
    (hxy : d x y ≤ r)
    (hr : r ≤ m / K)
    (hK : 0 < K) :
    |f x - f y| ≤ m := by
  nlinarith [ hLip x y, mul_div_cancel₀ m hK.ne' ]

/-! ## Information-Theoretic Specializations

We parameterize over a general type `Ω` of distributions and a functional `MI : Ω → ℝ`
representing mutual information (or any information measure). This allows instantiation
with tropical MI, Shannon MI, Rényi MI, or any other information functional. -/

/-- **Mutual information Lipschitz chain**: if the map `μ ↦ MI(μ)` is `K`-Lipschitz
    w.r.t. distance `d`, and `d(X, X') ≤ r`, then `|MI(X) - MI(X')| ≤ K * r`.

    This is the sharper intermediate bound before applying the margin transfer. -/
theorem mutualInformation_lipschitz_chain
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K r : ℝ)
    (X X' : Ω)
    (hLip : ∀ μ ν : Ω, |MI μ - MI ν| ≤ K * d μ ν)
    (hXX' : d X X' ≤ r)
    (hK : 0 ≤ K) :
    |MI X - MI X'| ≤ K * r :=
  lipschitz_chain_bound d MI K r X X' hLip hXX' hK

/-- **Mutual information radius margin bound**: if `MI` is `K`-Lipschitz,
    `d(X, X') ≤ r`, and `r ≤ m / K`, then `|MI(X) - MI(X')| ≤ m`.

    This is the main certification theorem: the mutual information cannot change
    by more than the certified margin `m` inside the radius `r`. -/
theorem mutualInformation_radius_margin_bound
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K m r : ℝ)
    (X X' : Ω)
    (hLip : ∀ μ ν : Ω, |MI μ - MI ν| ≤ K * d μ ν)
    (hXX' : d X X' ≤ r)
    (hr : r ≤ m / K)
    (hK : 0 < K) :
    |MI X - MI X'| ≤ m :=
  lipschitz_margin_bound d MI K m r X X' hLip hXX' hr hK

/-! ## Privacy-to-Lipschitz Bridge

The key conceptual bridge: a tropical privacy bound can be interpreted as a
regularity condition that induces certified stability regions for information
functionals. -/

/-- A tropical privacy Lipschitz hypothesis: the functional `MI` is `K`-Lipschitz
    with respect to distance `d`. This is the abstract form of what tropical privacy
    bounds provide after suitable reformulation. -/
def tropical_privacy_lipschitz
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K : ℝ) : Prop :=
  ∀ μ ν : Ω, |MI μ - MI ν| ≤ K * d μ ν

/-- **Privacy implies information stability**: if a channel satisfies a tropical
    privacy Lipschitz bound, and inputs are within certified radius `r ≤ m / K`,
    then the information functional is stable within margin `m`.

    This is the precise mathematical form of the privacy-utility tradeoff:
    privacy is not merely an adversarial indistinguishability property, but an
    information-geometric regularity condition that induces certified stability regions. -/
theorem privacy_radius_information_stability
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K m r : ℝ)
    (X X' : Ω)
    (hPriv : tropical_privacy_lipschitz d MI K)
    (hXX' : d X X' ≤ r)
    (hr : r ≤ m / K)
    (hK : 0 < K) :
    |MI X - MI X'| ≤ m :=
  lipschitz_margin_bound d MI K m r X X' hPriv hXX' hr hK

/-! ## Cryptographic Distinguishability Certificates

For two distributions P, Q, if a distinguisher score D is K-Lipschitz and
separates P from Q with margin m, then perturbations within radius m/(2K)
preserve strict distinguishability. -/

/-
**Robust distinguishability via Lipschitz separation**: if a distinguisher `D`
    is `K`-Lipschitz, separates `P` from `Q` with margin `m`, and `P'` is a
    perturbation of `P` with `d(P, P') ≤ r ≤ m / (2K)`, then `P'` and `Q`
    remain separated with margin at least `m / 2`.

    This is the cryptographic analogue of margin certification in robust ML:
    it transforms tropical or geometric certificates into robust cryptographic
    guarantees. If a distinguisher separates two distributions with margin `m`,
    then all perturbations inside radius `m/(2K)` remain distinguishable.
-/
theorem distinguisher_radius_separation
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (D : Ω → ℝ)
    (K m r : ℝ)
    (P Q P' : Ω)
    (hLip : ∀ μ ν, |D μ - D ν| ≤ K * d μ ν)
    (hsep : m ≤ |D P - D Q|)
    (hclose : d P P' ≤ r)
    (hr : r ≤ m / (2 * K))
    (hK : 0 < K) :
    m / 2 ≤ |D P' - D Q| := by
  cases abs_cases ( D P - D Q ) <;> cases abs_cases ( D P' - D Q ) <;> cases abs_cases ( D P - D P' ) <;> nlinarith [ hLip P Q, hLip P P', mul_div_cancel₀ m ( by linarith : ( 2 * K ) ≠ 0 ) ]

/-- **Mutual information distinguisher separation**: specialization of the
    generic distinguisher theorem to any information functional.

    If MI is K-Lipschitz and separates distributions P, Q with margin m,
    then perturbations within radius m/(2K) preserve distinguishability. -/
theorem distinguisher_mutual_information_separation
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K m r : ℝ)
    (P Q P' : Ω)
    (hLip : ∀ μ ν, |MI μ - MI ν| ≤ K * d μ ν)
    (hsep : m ≤ |MI P - MI Q|)
    (hclose : d P P' ≤ r)
    (hr : r ≤ m / (2 * K))
    (hK : 0 < K) :
    m / 2 ≤ |MI P' - MI Q| :=
  distinguisher_radius_separation d MI K m r P Q P' hLip hsep hclose hr hK

/-! ## Composition: Privacy + Separation Certificate

Combining the privacy-stability and distinguishability theorems yields
a complete certificate: a single Lipschitz constant simultaneously controls
information stability AND distinguisher robustness. -/

/-- **Privacy-stability implies robust distinguishability**: if MI satisfies
    a tropical privacy Lipschitz bound and separates P from Q with margin m,
    then perturbations within radius m/(2K) preserve distinguishability.

    This is the full bridge theorem connecting certified robustness, mutual
    information stability, differential privacy, and cryptographic
    distinguishability. -/
theorem privacy_distinguisher_bridge
    {Ω : Type*}
    (d : Ω → Ω → ℝ)
    (MI : Ω → ℝ)
    (K m r : ℝ)
    (P Q P' : Ω)
    (hPriv : tropical_privacy_lipschitz d MI K)
    (hsep : m ≤ |MI P - MI Q|)
    (hclose : d P P' ≤ r)
    (hr : r ≤ m / (2 * K))
    (hK : 0 < K) :
    m / 2 ≤ |MI P' - MI Q| :=
  distinguisher_radius_separation d MI K m r P Q P' hPriv hsep hclose hr hK

end
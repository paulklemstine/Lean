# Future Directions: Tropical Arithmetic Lensing

## Overview

This document outlines five concrete breakthrough research directions opened by the formal development of tropical arithmetic lensing on the Berggren tree. Each direction includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Multiplicity-Sensitive Caustics — Recovering Prime Exponents

### Goal
Extend caustic rigidity from prime *support* to prime *exponents*. The current framework determines *which* primes divide a number; the next step determines *how many times* each prime divides it.

### Concrete Theorem Target
```
theorem caustic_rigidity_multiplicity (n m : ℕ) (S : Finset ℕ)
    (hsuff : MultiplicitySufficientProbe n m S)
    (hprof : multiplicityProfile n S = multiplicityProfile m S) :
    n.factorization = m.factorization
```

### Key Definition
```
def multiplicityProfile (n : ℕ) (S : Finset ℕ) : Finset (ℕ × ℕ) :=
  S.biUnion (fun s =>
    (Nat.gcd n s).factorization.support.image
      (fun p => (p, padicValNat p (Nat.gcd n s))))
```

### Proof Strategy
1. Define a valuation-weighted interaction profile that records `(p, v_p(gcd(n,s)))` pairs.
2. Show that if the probe set contains elements with sufficient p-adic depth (i.e., `p^k | s` for each relevant prime power `p^k | n`), then the multiplicity profile determines the full factorization.
3. The key lemma is: if `v_p(gcd(n, s)) = min(v_p(n), v_p(s))` and the probe set contains elements with `v_p(s) ≥ v_p(n)`, then `v_p(n)` is exactly recovered.

### Cross-Domain Connection
This connects tropical arithmetic lensing to p-adic analysis: the multiplicity profile is essentially a finite sampling of the p-adic valuation landscape, and the sufficiency condition is a p-adic density requirement.

---

## Direction 2: Min-Plus Transfer Operators and Spectral Gaps

### Goal
Formalize the Berggren child maps as a min-plus transfer operator on height functions, and prove spectral gap properties that control the convergence of caustic profiles with depth.

### Concrete Theorem Targets
```
def BerggrenTransferOperator (f : PrimPythTriple → ℝ) : PrimPythTriple → ℝ :=
  fun t => min (min (f (childA t) + wA t) (f (childB t) + wB t)) (f (childC t) + wC t)

theorem transfer_operator_contraction (f g : PrimPythTriple → ℝ)
    (hfg : ∀ t, |f t - g t| ≤ ε) :
    ∀ t, |BerggrenTransferOperator f t - BerggrenTransferOperator g t| ≤ ε

theorem spectral_gap_lower_bound :
    ∃ λ > 0, ∀ depth ≥ D₀,
      profileDiameter (causticProfile depth) ≤ C * exp (-λ * depth)
```

### Proof Strategy
1. The transfer operator is a contraction in the sup-norm (1-Lipschitz by the nonexpansiveness of min).
2. The spectral gap arises from the strict hypotenuse growth: each child map increases height by a factor ≥ 2, giving exponential convergence of normalized profiles.
3. Use the tropical distance theory from `TropicalOneWayFunctions.lean` (tropDist triangle inequality) to bound operator norms.

### Cross-Domain Connection
This bridges tropical algebra to dynamical systems and statistical mechanics: the transfer operator is a discrete analogue of the Ruelle-Perron-Frobenius operator, and the spectral gap controls mixing rates of the "tropical heat equation" on the Berggren tree.

---

## Direction 3: Arithmetic Wavefront Sets on Pythagorean Moduli Trees

### Goal
Define an arithmetic wavefront set (microlocal support) for integers on the Berggren tree, analogous to the wavefront set in microlocal analysis. The wavefront set records the "directions" (tree branches) along which the factorization signature creates singularities in the tropical profile.

### Concrete Definitions
```
def arithmeticWavefrontSet (n : ℕ) (depth : ℕ) : Finset (List BerggrenStep) :=
  -- Paths in the Berggren tree where the tropical profile of n
  -- exhibits a "jump" (prime interaction appears or disappears)
  ...

def isSingularPath (n : ℕ) (path : List BerggrenStep) : Prop :=
  ∃ p ∈ n.primeFactors,
    p ∣ (applyPath path).2.2 ∧
    ∀ prefix ∈ path.inits.dropLast, ¬(p ∣ (applyPath prefix).2.2)
```

### Theorem Target
```
theorem wavefront_set_determines_support (n m : ℕ)
    (hwf : arithmeticWavefrontSet n depth = arithmeticWavefrontSet m depth) :
    n.primeFactors = m.primeFactors
```

### Proof Strategy
Each prime p that divides n creates a wavefront (first path where p appears in the hypotenuse). Equal wavefront sets mean the same primes "arrive" at the same tree positions, which forces equal prime supports. This is a refinement of caustic rigidity where the *geometry* of the profile, not just its values, encodes arithmetic data.

### Cross-Domain Connection
This imports the language of microlocal analysis into discrete arithmetic geometry: the wavefront set is the arithmetic analogue of the set of "codirections of propagation of singularities."

---

## Direction 4: Tropical Scattering and Diophantine Reconstruction

### Goal
Define a tropical scattering matrix for the Berggren tree that encodes how min-plus signals propagate through the tree. Prove that the scattering data determines factorization signatures, analogous to inverse scattering in mathematical physics.

### Concrete Definitions
```
def tropicalScatteringMatrix (n : ℕ) (depthIn depthOut : ℕ) :
    Matrix (Fin (3^depthIn)) (Fin (3^depthOut)) ℕ :=
  -- Entry (i,j) = minimal tropical action from input path i to output path j
  -- that passes through a node interacting with n
  ...

def scatteringProfile (n : ℕ) (depth : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  -- (inputPath, outputPath, minAction) triples
  ...
```

### Theorem Target
```
theorem scattering_rigidity (n m : ℕ) (depth : ℕ)
    (hprof : scatteringProfile n depth = scatteringProfile m depth) :
    n.primeFactors = m.primeFactors
```

### Proof Strategy
1. The scattering matrix records how tropical geodesics are "deflected" by the arithmetic interaction with n.
2. Different prime factors create distinguishable scattering patterns because they affect different tree branches.
3. The inversion formula recovers prime supports from the scattering data.

### Cross-Domain Connection
This connects tropical arithmetic lensing to inverse scattering theory from mathematical physics. The Berggren tree plays the role of a discrete medium, the integer n creates a "potential," and the scattering data encodes the potential's structure.

---

## Direction 5: Complexity-Theoretic Bounds for Caustic-Based Factoring

### Goal
Analyze the computational complexity of the caustic-based factoring algorithm. Determine the depth (probe set size) needed to factor n, and compare with known factoring algorithm complexities.

### Concrete Theorem Targets
```
-- Upper bound: depth O(log n) suffices for reconstruction
theorem reconstruction_depth_upper_bound (n : ℕ) (hn : 1 < n) :
    ∃ D ≤ C * Nat.log 2 n,
      IsSufficientProbeSet n (berggrenHypotenuses D)

-- Lower bound: sublinear depth cannot suffice in general
theorem reconstruction_depth_lower_bound :
    ∃ n, ∀ D < Nat.log 2 n / C,
      ¬IsSufficientProbeSet n (berggrenHypotenuses D)

-- Size of candidate set
theorem candidate_set_polynomial_bound (n depth : ℕ) :
    (reconstructCandidates (integerCausticProfile n depth)).card ≤ 3^depth
```

### Proof Strategy
1. **Upper bound**: Use the density of Pythagorean hypotenuses among numbers with prime factors ≡ 1 (mod 4). By Landau's theorem, the count of such hypotenuses ≤ x is Θ(x / √(log x)), ensuring sufficient coverage at logarithmic depth.
2. **Lower bound**: Construct numbers whose smallest prime factor ≡ 1 (mod 4) is large, requiring deep tree traversal.
3. **Candidate bound**: At depth D, there are 3^D triples, each contributing at most one prime to the candidate set.

### Cross-Domain Connection
This connects tropical arithmetic lensing to computational number theory and complexity theory. The question "how deep must we look into the Berggren tree to see all prime factors?" is a new complexity measure for integers, related to the distribution of primes in arithmetic progressions.

---

## Research Program Summary

These five directions form a coherent research program:

| Direction | Key Innovation | Connects To |
|-----------|---------------|-------------|
| 1. Multiplicity | Full factorization recovery | p-adic analysis |
| 2. Spectral gaps | Convergence guarantees | Dynamical systems |
| 3. Wavefront sets | Geometric profile analysis | Microlocal analysis |
| 4. Scattering | Inverse problem framework | Mathematical physics |
| 5. Complexity | Algorithmic analysis | Computational number theory |

The unifying theme is **tropical arithmetic tomography**: using min-plus geometric propagation on canonical discrete moduli spaces to detect, encode, and reconstruct arithmetic structure.

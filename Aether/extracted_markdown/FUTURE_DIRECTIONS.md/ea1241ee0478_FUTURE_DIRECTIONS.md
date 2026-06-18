# Future Directions: Semiconjugacy Orbit Arithmetic

This document outlines five concrete research directions opened by the formalized theory of period transport under semiconjugacy.

---

## 1. Conjugacy Invariance of the Full Period Spectrum

**Theorem target:**
For a conjugacy `e : α ≃ β` with `e ∘ f = g ∘ e`, the full period spectra coincide:
```
{n : ℕ | IsPeriodicPt f n x} = {n : ℕ | IsPeriodicPt g n (e x)}
```

**Proof strategy:**
Each direction follows from `isPeriodicPt_iff_of_injective` applied to `e` and `e⁻¹`. The forward inclusion is `isPeriodicPt_image`; the reverse uses `e.symm` as a semiconjugacy from `g` to `f`.

**Cross-domain significance:**
This upgrades from "minimal period is a conjugacy invariant" to "the entire divisibility lattice of periods is invariant." It enables certified classification of conjugacy classes by period spectra in finite dynamical systems—critical for automata equivalence testing and symbolic dynamics classification.

---

## 2. Eventual Periodicity Descent and Ascent

**Theorem targets:**
```lean
-- Descent (no extra hypothesis)
theorem Semiconj.isEventuallyPeriodicPt_image (hsc : Semiconj h f g)
    (hx : ∃ m n, 0 < n ∧ f^[m + n] x = f^[m] x) :
    ∃ m' n', 0 < n' ∧ g^[m' + n'] (h x) = g^[m'] (h x)

-- Ascent (requires injectivity)
theorem Semiconj.isEventuallyPeriodicPt_of_injective (hsc : Semiconj h f g)
    (hinj : Injective h) (hy : eventually periodic g at h x) :
    eventually periodic f at x
```

**Proof strategy:**
Descent follows by applying `h` to both sides of `f^[m+n] x = f^[m] x` and using the iterate transport identity. Ascent under injectivity mirrors the proof of `isPeriodicPt_iff_of_injective`. The tail length (preperiod) satisfies `m' ≤ m` for descent; characterizing the exact relationship requires the next direction.

**Cross-domain significance:**
Eventual periodicity captures the behavior of state machines after transient initialization. Descent means that any abstraction of an eventually periodic system is eventually periodic—critical for termination analysis in abstract interpretation and model checking.

---

## 3. Cycle Counting on Finite Types

**Theorem targets:**
For `[Fintype α]` and `[Fintype β]` with semiconjugacy `h`:
```lean
-- Number of periodic orbits of length n in the factor divides
-- or is bounded by the number upstairs
theorem card_periodicPts_n_le (hsc : Semiconj h f g) (hsurj : Surjective h) (n : ℕ) :
    (Finset.filter (fun y => IsPeriodicPt g n y) Finset.univ).card ≤
    (Finset.filter (fun x => IsPeriodicPt f n x) Finset.univ).card
```

**Proof strategy:**
Surjectivity of `h` combined with `isPeriodicPt_image` gives a surjection from periodic points upstairs to periodic points downstairs (restricted to period `n`). Apply `Finset.card_le_card_of_surjOn`. For exact counts, use the fiber decomposition: each periodic orbit downstairs is the image of one or more periodic orbits upstairs, with orbit lengths related by divisibility.

**Cross-domain significance:**
This connects to the Artin–Mazur dynamical zeta function `ζ_f(z) = exp(Σ |Fix(f^n)|/n · z^n)`. The divisibility constraints on periods imply divisibility constraints on fixed-point counts, yielding rationality criteria for factor zeta functions. In finite-state automata, this gives certified bounds on the number of distinct cyclic behaviors observable through a homomorphic image.

---

## 4. Commuting Maps and LCM/GCD Structure of Periods

**Theorem targets:**
If `f ∘ g = g ∘ f` (i.e., `Commute f g`), then for any `x`:
```lean
-- The minimal period of x under f·g divides lcm of individual periods
theorem minimalPeriod_comp_dvd_lcm (hcomm : Commute f g) (x : α) :
    minimalPeriod (f ∘ g) x ∣ Nat.lcm (minimalPeriod f x) (minimalPeriod g x)

-- Joint periodicity from individual periodicity
theorem isPeriodicPt_comp_of_comm (hcomm : Commute f g) {n m : ℕ}
    (hf : IsPeriodicPt f n x) (hg : IsPeriodicPt g m x) :
    IsPeriodicPt (f ∘ g) (Nat.lcm n m) x
```

**Proof strategy:**
`Commute f g` means `Semiconj f g g` (and also `Semiconj g f f`). Use iterate-transport to show that `(f ∘ g)^[lcm(n,m)] = f^[lcm(n,m)] ∘ g^[lcm(n,m)]` (this uses commutativity). Since `lcm(n,m)` is divisible by both `n` and `m`, both factors fix `x`.

**Cross-domain significance:**
Commuting dynamics arise in integrable systems (action-angle coordinates), number theory (Hecke operators), and cryptography (commuting permutations in group-based protocols). The LCM structure of periods under composition is the arithmetic backbone of multi-key cryptosystem cycle analysis.

---

## 5. Symbolic Dynamics Bridge: Factor Maps for Shift Systems

**Theorem targets:**
Define a (one-sided) shift system on sequences `ℕ → Fin k` with the shift map `σ(x)(n) = x(n+1)`, and a block map (sliding-window factor) as a semiconjugacy to a lower-alphabet shift:
```lean
def shift (k : ℕ) : (ℕ → Fin k) → (ℕ → Fin k) := fun x n => x (n + 1)

-- A block map of window size w induces a semiconjugacy
theorem blockMap_semiconj (Φ : (Fin w → Fin k) → Fin l) :
    Semiconj (fun x n => Φ (fun i => x (n + i))) (shift k) (shift l)

-- Periodic orbit divisibility as corollary
theorem shift_factor_minimalPeriod_dvd (Φ : (Fin w → Fin k) → Fin l) (x : ℕ → Fin k) :
    minimalPeriod (shift l) ((fun x n => Φ (fun i => x (n + i))) x) ∣
    minimalPeriod (shift k) x
```

**Proof strategy:**
The block map semiconjugacy follows from the definition: applying the shift then the block map equals applying the block map to the shifted sequence. The period divisibility is then a direct application of `minimalPeriod_image_dvd`.

**Cross-domain significance:**
This is the entry point to formal symbolic dynamics. Curtis–Hedlund–Lyndon theorem states that every continuous shift-commuting map between full shifts is a block map—so our abstract semiconjugacy theorem immediately yields period constraints for the entire class of symbolic dynamical factor maps. Applications include:
- Coding theory: constrained codes as shift-of-finite-type factors
- Cellular automata: period constraints on spacetime patterns under local rules
- Data compression: relationship between source and coded sequence periodicities

---

## Research Methodology

Each direction should be pursued by:
1. **Formalize definitions** in a new Lean file importing the core module.
2. **State the main theorem** with `by sorry` and verify it type-checks.
3. **Decompose** into 3–5 helper lemmas, each capturing one proof step.
4. **Prove bottom-up** from simplest to most complex.
5. **Cross-validate** with computational examples using `#eval` on small instances.
6. **Document** cross-domain connections in module docstrings.

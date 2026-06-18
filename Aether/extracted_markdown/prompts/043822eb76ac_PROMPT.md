Formalize a clean, self-contained Lean 4 development for the dynamical notion originally intended by the project, and discard the unrelated ECOC / robustness material.

Create a coherent file proving the following theorem suite for iterates of a self-map.

1. Definitions.
- For `f : X → X` and `x : X`, define
  `HaltsAt (f : X → X) (x : X) : Prop := ∃ m n : ℕ, m < n ∧ (f^[m]) x = (f^[n]) x`.
- Define
  `Unstoppable (f : X → X) : Prop := ∀ x : X, Function.Injective (fun n : ℕ => (f^[n]) x)`.

2. Basic equivalence.
Prove that for every `x`,
- `HaltsAt f x` implies the orbit map `fun n => (f^[n]) x` is not injective.
- conversely, noninjectivity of the orbit map implies `HaltsAt f x`.
Hence derive a clean theorem expressing `Unstoppable f` in terms of `¬ HaltsAt f x` for all `x`.

3. Drift criterion over integers.
Assume `φ : X → ℤ` and `c : ℤ` satisfy
- `0 < c`
- `∀ x, φ (f x) = φ x + c`
Prove the iterate formula
- `φ ((f^[n]) x) = φ x + n * c`
for all `n`.
Then prove the main theorem
- `unstoppable_of_drift_int : Unstoppable f`.
The proof should be by contradiction: if `(f^[m]) x = (f^[n]) x` with `m < n`, then applying `φ` and the iterate formula gives
  `φ x + m * c = φ x + n * c`, hence `m * c = n * c`, contradicting `m < n` and `0 < c`.
Use standard integer order/cancellation lemmas.

4. Optional mild generalization only if clean.
If Lean support is straightforward, add a version for a linearly ordered additive cancellative monoid/group target. But do not get stuck on abstraction. A complete and elegant `ℤ` development is preferred over an unfinished general theorem.

5. Concrete examples.
Include small example theorems instantiating the criterion, for example:
- `f z = z + 1` on `ℤ`, with `φ = id`, `c = 1`.
- a map on `ℤ × ℤ` such as `f (a,b) = (a+1,b)` with potential `φ (a,b) = a`.
Show these maps are `Unstoppable`.

6. File quality constraints.
- The file must be standalone, focused, and free of unrelated theorem statements.
- No placeholders, no `sorry`, no unfinished definitions.
- Prefer short helper lemmas with clear names.
- Use existing iterate lemmas from Mathlib where convenient.

The prior attempt failed because it wandered into unrelated topics and left many declarations incomplete. This retry should be a compact formalization of the exact dynamical theorem suite above.
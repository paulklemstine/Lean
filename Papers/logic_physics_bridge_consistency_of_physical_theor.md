# Computational Evidence — Logic–Physics Bridge: Consistency of Physical Theories

All numbers below are produced by `#eval` on the *executable* models defined in
`Provability.lean` (`eval` = box-true Boolean model; `sat m` = standard Kripke model on
the converse-well-founded frame `(ℕ, n < m)`). They are evidence for, and were used to
debug, the formal theorems; the theorems themselves are fully proved (0 `sorry`, only
`propext`/`Classical.choice`/`Quot.sound`).

Notation: `Con i = ¬ □ᵢ⊥` is the object-level consistency sentence of theory `i`.

## 1. Box-true Boolean model (`eval`) — consistent but NOT Σ₁-sound

| formula        | `eval` value |
|----------------|--------------|
| `Con 0`        | `false`      |
| `box 0 ⊥`      | `true`       |

Reading: `eval ⊥ = false` so this theory is **consistent**, yet it makes `box 0 ⊥`
(`"⊥ is provable"`) **true** — it asserts its own inconsistency. Hence it is *not*
Σ₁-sound and cannot witness the negation half of independence. This is exactly why a
second, genuine model is needed.

## 2. Standard Kripke model (`sat m`) across worlds m = 0,1,2,3

| formula                                            | worlds 0..3            |
|----------------------------------------------------|------------------------|
| `Con 0`                                            | `[false, true, true, true]` |
| `box 0 ⊥`                                          | `[true, false, false, false]` |
| `¬ Con 0`                                          | `[true, false, false, false]` |
| Löb axiom at `⊥`: `□(□⊥→⊥) → □⊥`                   | `[true, true, true, true]` |
| bridge `Con 1 → Con 0`                             | `[true, true, true, true]` |

Readings (a formula is a *theorem* iff it is `true` at **every** world):

* `Con 0` is `false` at world `0` ⇒ **`stdSys ⊬ Con 0`** (Gödel II).
* `¬ Con 0` is `false` at world `1` ⇒ **`stdSys ⊬ ¬ Con 0`**.
  Together: `Con 0` is **independent** of `stdSys`.
* `box 0 ⊥` is `false` at world `1` ⇒ **`stdSys ⊬ □⊥`** (Σ₁-soundness about
  consistency).
* The Löb axiom (instance `a := ⊥`) is `true` everywhere ⇒ a theorem; this is the
  converse-well-foundedness of `<` made computational (`box_a_valid`).
* The interpretation bridge `Con(T) → Con(PA)` is `true` everywhere ⇒ a theorem; the
  hypothesis `hbridge` of `con_T_independent_of_PA` is therefore satisfiable (here even
  by the same model for both `PA` and `T`).

## 3. Counterexample hunt (upward transfer of consistency)

Claim tested: *does consistency of the base imply consistency of every extension?*
Counterexample found and formalized as `math_not_implies_physical`:

* `PA := trueSys` — consistent GL theory (`eval ⊥ = false`).
* `T := trivialSys` — proves every formula, in particular `⊥`, so inconsistent, yet
  `Simulates T PA` holds (it proves everything `PA` proves).

So consistency does **not** transfer upward along `Simulates`. (It does transfer
*downward*: `physical_implies_math`.)

## 4. OEIS

No integer sequence is central to this proof-theoretic development, so no OEIS lookup
applies. The only numerical content is the per-world truth tables above, which are
finite Boolean vectors rather than a growing integer sequence.

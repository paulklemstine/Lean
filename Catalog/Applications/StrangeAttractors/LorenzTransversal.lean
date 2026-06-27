/-
# Strange Attractors as Algebraic Objects — III. The Cantor Transversal

The transverse Cantor set of a Lorenz-type / solenoidal attractor is the inverse
limit of the finite *cyclic* directed graphs `ℤ/2ⁿℤ` under the doubling
quotients

      ℤ/1  ⟵  ℤ/2  ⟵  ℤ/4  ⟵  ℤ/8  ⟵  ⋯        (reduction mod `2ⁿ`).

These reduction maps are exactly graph morphisms of finite directed graphs (the
oriented `2ⁿ`-cycles), so the inverse limit lives in the category of finite
directed graphs — instantiating the mission's central conjecture in a verifiable
case.  The inverse limit is the ring of `2`-adic integers `ℤ₂`, a Cantor set.

## Main results

* `dyadicTower`               — the inverse system of cyclic graphs `ℤ/2ⁿ`.
* `dyadicTower_bond_surjective` — the reduction maps are onto.
* `dyadicTower_nonempty`      — the transversal is nonempty (via the engine of
    file I, `InvLimit.nonempty_of_surjective`).
* `intThread` / `intThread_injective` — every integer gives a compatible thread,
    injectively (the dense `ℤ ↪ ℤ₂`).
* `dyadicTower_infinite`      — **the transversal is infinite** (a Cantor set,
    not a finite graph): there is no finite stage at which it stabilises.

This is the **cross-domain bridge** target: it realises a dynamical transversal
as an honest categorical inverse limit of finite directed graphs and certifies
its non-finiteness through the algebra of `ℤ → ℤ/2ⁿ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The transverse Cantor set of the solenoid is the
inverse limit of the oriented `2ⁿ`-cycles, and it is genuinely infinite.
Experiment (Experimenter): Instantiated the file-I engine with `obj n = ZMod 2ⁿ`
and bonding maps `ZMod.castHom`.  Surjectivity ⇒ nonemptiness for free.  Built
`ℤ → InvLimit` by reducing an integer mod `2ⁿ`; injectivity follows because the
only integer divisible by every `2ⁿ` is `0`.  Infinite-ness is then `Infinite.of_injective`.
Analysis (Analyst): The reduction maps `ring`-commute with `Int.cast` (`map_intCast`),
which is what makes the integer threads compatible; the depth is the
`∀ n, 2ⁿ ∣ d → d = 0` archimedean step.  "True, moderately easy."
Critique (Critic): Not vacuous — `dyadicTower_infinite` is a real `Infinite`
instance, and the integer embedding is genuinely injective (witnessed), not a
renaming.  Reuses the file-I theorem, so the engine is load-bearing.
Synthesis (PI): Finite graphs at every stage, infinite in the limit — the
qualitative jump from approximant to attractor, made precise.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Applications.StrangeAttractors.InverseLimit

namespace StrangeAttractors

open scoped Classical

/-- The inverse system of cyclic directed graphs `ℤ/2ⁿ` with reduction-mod-`2ⁿ`
bonding maps: the finite-graph diagram whose inverse limit is the `2`-adic
transversal of the solenoid. -/
def dyadicTower : InvSystem where
  obj n := ZMod (2 ^ n)
  bond n := ZMod.castHom (pow_dvd_pow 2 (Nat.le_succ n)) (ZMod (2 ^ n))

/-- The reduction maps of the tower are surjective. -/
theorem dyadicTower_bond_surjective (n : ℕ) :
    Function.Surjective (dyadicTower.bond n) :=
  ZMod.castHom_surjective _

/-- The `2`-adic transversal is nonempty: the engine of file I applies. -/
theorem dyadicTower_nonempty : Nonempty (InvLimit dyadicTower) :=
  InvLimit.nonempty_of_surjective dyadicTower dyadicTower_bond_surjective
    ⟨(0 : ZMod (2 ^ 0))⟩

/-- The compatible thread attached to an integer `k`: its residues mod `2ⁿ`. -/
def intThread (k : ℤ) : InvLimit dyadicTower :=
  ⟨fun n => (k : ZMod (2 ^ n)), by
    intro n
    -- the bonding (cast) ring hom sends `Int.cast k` to `Int.cast k`
    exact map_intCast (ZMod.castHom (pow_dvd_pow 2 (Nat.le_succ n)) (ZMod (2 ^ n))) k⟩

/-
Distinct integers give distinct threads (the dense embedding `ℤ ↪ ℤ₂`).
-/
theorem intThread_injective : Function.Injective intThread := by
  intros a b hab
  have h_eq : ∀ n, (a : ZMod (2 ^ n)) = (b : ZMod (2 ^ n)) := by
    exact fun n => congr_fun ( Subtype.ext_iff.mp hab ) n;
  -- Let $d = a - b$. For each $n$, $(d : ℤ) : ZMod (2^n) = 0$, so by $ZMod.intCast_zmod_eq_zero_iff_dvd$, $(2^n : ℤ) ∣ d$.
  set d : ℤ := a - b
  have hd : ∀ n, (2 ^ n : ℤ) ∣ d := by
    intro n; specialize h_eq n; erw [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ; aesop;
  contrapose! hd;
  -- Since $d \neq 0$, there exists some $n$ such that $2^n > |d|$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, 2 ^ n > |d| := by
    exact pow_unbounded_of_one_lt _ one_lt_two;
  exact ⟨ n, fun h => hn.not_ge <| Int.le_of_dvd ( abs_pos.mpr <| sub_ne_zero.mpr hd ) <| by simpa using h ⟩

/-- **The transversal is infinite** — a Cantor set, not any finite graph. -/
theorem dyadicTower_infinite : Infinite (InvLimit dyadicTower) :=
  Infinite.of_injective intThread intThread_injective

end StrangeAttractors
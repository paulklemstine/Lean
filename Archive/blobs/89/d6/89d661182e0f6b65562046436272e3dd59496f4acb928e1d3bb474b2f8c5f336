/-
# Identity Systems II: Converse, Eliminator, Closure, and the Mathlib Bridge

This file is the *next research cycle* on the catalog's synthetic-HoTT layer. The
previous cycle (`Catalog/Logic/HoTT/IdentitySystems.lean`) proved the
**Fundamental Theorem of Identity Systems** (`fundamentalIdentitySystem`):
an `IdentitySystem A a₀ R` yields a fibrewise equivalence `(a₀ = a) ≃' R a`.

Here we close four of the research directions opened by that cycle, all
`sorry`-free and depending only on `propext`:

* **Direction 1 — the converse.** `idSys_of_fiber_equiv`: a family `R` that is
  fibrewise equivalent to the based path family `a₀ = ·` is itself an identity
  system. Together with `fundamentalIdentitySystem` this gives the genuine
  *characterisation*: `R` is an identity system **iff** it is fibrewise
  equivalent to the path family. The proof reuses the catalog's
  `Equiv'.contractible` to transport contractibility of the path total space
  across an assembled `Σ'`-equivalence `Equiv'.psigmaCongr`.

* **Direction 3 — closure under products.** `idSys_prod`: the product of two
  identity systems is an identity system on the product, via `Contractible.prod`
  and the regrouping equivalence `Equiv'.sigmaProd`.

* **Direction 4 — a `J`/path-induction eliminator.** `idSysElim` with its
  computation rule `idSysElim_beta`: every identity system induces its own
  dependent eliminator that reduces to the base case on the reflexivity witness,
  exactly like `Eq.rec` does for the based path family.

* **Direction 5 — the bridge to Mathlib.** `Equiv'.toEquiv` repackages the
  catalog's bespoke `Equiv'` as a Mathlib `Equiv`, and
  `fundamentalIdentitySystemEquiv` exports the fundamental theorem as an honest
  `(a₀ = a) ≃ R a`, importable into mainstream Mathlib developments.

## Relationship to catalog
- Reuses `HoTTFound.Contractible`, `Equiv'`, `Equiv'.symm`, `Equiv'.contractible`,
  `IdentitySystem`, `contractible_based_paths`, `fundamentalIdentitySystem` from
  `Foundations.lean` / `IdentitySystems.lean`; adds only new declarations.

-- !-- Lab Notebook -- !--
Hypothesis: The fundamental theorem of identity systems should be reversible
  (a fibrewise equivalence to the path family characterises identity systems),
  should generate its own eliminator, should be closed under products, and should
  embed into Mathlib's `Equiv` API — all derivable from the data already present
  in `Foundations.lean`/`IdentitySystems.lean` with no new axioms.
Result: All four confirmed and fully formalized (zero `sorry`). The converse
  (`idSys_of_fiber_equiv`) and product closure (`idSys_prod`) both reduce to a
  single move: build a `Σ'`-equivalence between total spaces and push
  contractibility across it with `Equiv'.contractible`. The eliminator
  (`idSysElim`) is transport of the base datum along the contractibility witness
  of the total space, and its `β`-rule (`idSysElim_beta`) holds because the
  relevant transport is along a *loop* in a `Prop`-valued `Eq`, hence `rfl` by
  proof irrelevance (`mpr_congr_loop`). The Mathlib bridge is a definitional
  repackaging since `Equiv'`'s two roundtrip laws are exactly Mathlib's
  `left_inv`/`right_inv`.
Insight: Contractibility transport along an `Equiv'` is the single reusable
  engine for the entire identity-system calculus: encode/decode (previous cycle),
  the converse, and closure properties all become one-line assemblies once the
  appropriate `Σ'`-equivalence is named. The eliminator's computation rule is
  "free" for the same reason the previous cycle's `left_inv` was free: `Eq` is a
  subsingleton, so every transport along a base loop is the identity.
Failure analysis: A direct `def idSysElim := pf ▸ d` was rejected (`motive is not
  type correct`) because the fibre lives over the moving base point; the fix is
  `Eq.mpr (congrArg (fun s => D s.1 s.2) pf) d`, transporting in the *total
  space* where the motive is a genuine function. Proving the β-rule by `rw`/`unfold`
  failed because the proof term sits opaquely inside `Eq.mpr`; abstracting the
  general lemma `mpr_congr_loop` (with the loop as a free variable) and applying
  it with explicit motive/loop arguments discharges it cleanly.
-- !-- end Lab Notebook -- !--
-/

import Mathlib
import Catalog.Logic.HoTT.IdentitySystems

universe u v w u' v'

namespace HoTTFound

variable {A : Sort u} {a₀ : A} {R : A → Sort v}

/-! ## Direction 1: the converse / characterisation -/

-- !-- A fibrewise family of equivalences assembles into one equivalence of
-- total spaces, acting as the identity on the base and the given equivalence on
-- each fibre. -- !--
/-- Fibrewise equivalences assemble into an equivalence of dependent-sum total
    spaces. This is the `Σ'`-congruence rule for `Equiv'`, the engine behind the
    converse and closure properties below. -/
def Equiv'.psigmaCongr {A : Sort u} {P : A → Sort v} {Q : A → Sort w}
    (e : ∀ a, P a ≃' Q a) : (Σ' a, P a) ≃' (Σ' a, Q a) where
  toFun := fun s => ⟨s.1, (e s.1).toFun s.2⟩
  invFun := fun s => ⟨s.1, (e s.1).invFun s.2⟩
  left_inv := fun ⟨a, x⟩ => by simp [(e a).left_inv]
  right_inv := fun ⟨a, y⟩ => by simp [(e a).right_inv]

-- !-- Push the contractibility of the based path total space `Σ' a, (a₀ = a)`
-- across the assembled fibrewise equivalence; the centre lands on `⟨a₀, e rfl⟩`,
-- which is exactly the required reflexivity witness, so `center_eq` is `rfl`. -- !--
/-- **Converse of the fundamental theorem (Direction 1).**

    If a family `R` is fibrewise equivalent to the based path family `a₀ = ·`,
    then `R` *is* an identity system based at `a₀` (with reflexivity witness the
    image of `rfl`). Combined with `fundamentalIdentitySystem` this characterises
    identity systems: `R` is an identity system iff it is fibrewise equivalent to
    the based path family. -/
def idSys_of_fiber_equiv (e : ∀ a, (a₀ = a) ≃' R a) : IdentitySystem A a₀ R where
  rflR := (e a₀).toFun rfl
  contr_total := Equiv'.contractible (Equiv'.psigmaCongr e) (contractible_based_paths a₀)
  center_eq := rfl

/-! ## Direction 4: the induced eliminator (path induction) -/

-- !-- A transport in a `Prop`-valued `Eq` along a loop `pf : x = x` is the
-- identity, because `pf = rfl` by proof irrelevance. -- !--
/-- Transport (`Eq.mpr ∘ congrArg`) along a *loop* is the identity. The technical
    engine for the eliminator's computation rule. -/
theorem mpr_congr_loop {X : Sort u} {x : X} {D : X → Sort w} (pf : x = x) (d : D x) :
    Eq.mpr (congrArg D pf) d = d := by
  have h : pf = rfl := proof_irrel _ _
  subst h
  rfl

-- !-- Given `r : R a`, the contractibility of `Σ' a, R a` makes `⟨a, r⟩` equal to
-- the centre `⟨a₀, rflR⟩`; transport the base datum `d` along that equality in the
-- total space. -- !--
/-- **The eliminator induced by an identity system (Direction 4).**

    Every identity system induces a dependent eliminator: to define a section of
    any `D : ∀ a, R a → Sort w` it suffices to give its value `d` on the
    reflexivity witness. This is the analogue of path induction (`Eq.rec`) for the
    family `R`. -/
def idSysElim (S : IdentitySystem A a₀ R) (D : (a : A) → R a → Sort w)
    (d : D a₀ S.rflR) (a : A) (r : R a) : D a r :=
  Eq.mpr (congrArg (fun s : Σ' x, R x => D s.1 s.2)
    ((S.contr_total.contr ⟨a, r⟩).trans S.center_eq)) d

-- !-- At the reflexivity witness the relevant transport is along a loop, hence
-- the identity by `mpr_congr_loop`. -- !--
/-- **Computation rule for the induced eliminator.**

    On the reflexivity witness, the eliminator reduces to the supplied base case,
    exactly as `Eq.rec` reduces on `rfl`. -/
theorem idSysElim_beta (S : IdentitySystem A a₀ R) (D : (a : A) → R a → Sort w)
    (d : D a₀ S.rflR) : idSysElim S D d a₀ S.rflR = d := by
  unfold idSysElim
  exact mpr_congr_loop (D := fun s : Σ' x, R x => D s.1 s.2)
    ((S.contr_total.contr ⟨a₀, S.rflR⟩).trans S.center_eq) d

/-! ## Direction 5: the bridge to Mathlib's `Equiv` -/

-- !-- The two roundtrip laws of `Equiv'` are definitionally Mathlib's
-- `left_inv`/`right_inv`, so this is a pure repackaging. -- !--
/-- The catalog's bespoke `Equiv'` forgets to a genuine Mathlib `Equiv`. -/
def Equiv'.toEquiv {α : Sort u} {β : Sort v} (e : α ≃' β) : α ≃ β :=
  ⟨e.toFun, e.invFun, e.left_inv, e.right_inv⟩

-- !-- Apply the forgetful bridge to the fundamental equivalence of the previous
-- cycle. -- !--
/-- **The fundamental theorem, exported to Mathlib (Direction 5).**

    The fundamental equivalence of an identity system as a Mathlib `Equiv`
    `(a₀ = a) ≃ R a`, making every catalog identity-system result importable into
    mainstream Mathlib developments (transport, `Equiv.subsingleton`, …). -/
def fundamentalIdentitySystemEquiv (S : IdentitySystem A a₀ R) (a : A) :
    (a₀ = a) ≃ R a :=
  (fundamentalIdentitySystem S a).toEquiv

/-! ## Direction 3: closure under products -/

-- !-- The centre is the pair of centres; any pair equals it componentwise. -- !--
/-- The product of two contractible types is contractible. -/
def Contractible.prod {α : Type u} {β : Type v}
    (h : Contractible α) (h' : Contractible β) : Contractible (α × β) where
  center := (h.center, h'.center)
  contr := fun y => by cases y; simp [h.contr, h'.contr]

-- !-- Reassociate `Σ' (p : A × A'), R p.1 × R' p.2` with the product of the two
-- separate total spaces; both roundtrips are `rfl`. -- !--
/-- The total space of the product family regroups into the product of the two
    total spaces. The `Σ'`-distribution equivalence over a product base. -/
def Equiv'.sigmaProd {A : Type u} {A' : Type u'} {R : A → Type v} {R' : A' → Type v'} :
    (Σ' (p : A × A'), R p.1 × R' p.2) ≃' ((Σ' a, R a) × (Σ' a', R' a')) where
  toFun := fun s => (⟨s.1.1, s.2.1⟩, ⟨s.1.2, s.2.2⟩)
  invFun := fun s => ⟨(s.1.1, s.2.1), s.1.2, s.2.2⟩
  left_inv := fun ⟨⟨_, _⟩, _, _⟩ => rfl
  right_inv := fun (⟨_, _⟩, ⟨_, _⟩) => rfl

-- !-- Contractibility of the product total space transports from the product of
-- contractibilities across `sigmaProd.symm`; the centre then reduces to the pair
-- of reflexivity witnesses by `center_eq` of each factor. -- !--
/-- **Closure of identity systems under products (Direction 3).**

    The product of two identity systems is an identity system on the product
    type, with the pointwise product family and the pair of reflexivity
    witnesses. -/
def idSys_prod {A : Type u} {a₀ : A} {R : A → Type v}
    {A' : Type u'} {a₀' : A'} {R' : A' → Type v'}
    (S : IdentitySystem A a₀ R) (S' : IdentitySystem A' a₀' R') :
    IdentitySystem (A × A') (a₀, a₀') (fun p => R p.1 × R' p.2) where
  rflR := (S.rflR, S'.rflR)
  contr_total := Equiv'.contractible Equiv'.sigmaProd.symm
    (Contractible.prod S.contr_total S'.contr_total)
  center_eq := by
    simp only [Equiv'.contractible, Equiv'.symm, Equiv'.sigmaProd, Contractible.prod]
    rw [S.center_eq, S'.center_eq]

end HoTTFound
import Mathlib

/-!
# Prime Temporal Congruence Spectrum for Reversible Oracle Semirings

This file develops the theory of **prime temporal congruences** for finite
reversible oracle semirings.

## Main results

* `TemporalSpectrum.canonicalEval_injective` — Representation theorem
* `TemporalSpectrum.orbit_eventually_periodic` — Pigeonhole periodicity
* `TemporalSpectrum.bijection_orbit_periodic` — Pure periodicity for bijections
* `TemporalSpectrum.temporal_orbit_periodic` — Temporal orbit periodicity
* `TemporalSpectrum.prime_temporal_separation` — Spectral separation theorem
* `TemporalSpectrum.spectralEval_separates` — Prime spectral injectivity
-/

namespace TemporalSpectrum

/-- A **temporal oracle semiring** structure on a semiring `R`. -/
structure TOS (R : Type*) [Semiring R] where
  tau : R ≃+* R
  rho : R ≃+* R
  Ω : Type*
  oracle : Ω → (R →+* R)
  rho_invol : ∀ x : R, rho (rho x) = x
  rho_tau : ∀ x : R, rho (tau x) = tau.symm (rho x)

variable {R : Type*} [Semiring R]

/-- A **temporal congruence**: an equivalence relation compatible with
all semiring and temporal structure. -/
structure TCong (T : TOS R) where
  rel : R → R → Prop
  rel_refl : ∀ x, rel x x
  rel_symm : ∀ {x y}, rel x y → rel y x
  rel_trans : ∀ {x y z}, rel x y → rel y z → rel x z
  rel_add : ∀ {a b a' b'}, rel a a' → rel b b' → rel (a + b) (a' + b')
  rel_mul : ∀ {a b a' b'}, rel a a' → rel b b' → rel (a * b) (a' * b')
  rel_tau : ∀ {a b}, rel a b → rel (T.tau a) (T.tau b)
  rel_rho : ∀ {a b}, rel a b → rel (T.rho a) (T.rho b)
  rel_oracle : ∀ (o : T.Ω) {a b}, rel a b → rel (T.oracle o a) (T.oracle o b)

variable {T : TOS R}

namespace TCong

def toSetoid (c : TCong T) : Setoid R where
  r := c.rel
  iseqv := ⟨c.rel_refl, @c.rel_symm, @c.rel_trans⟩

theorem ext' {c₁ c₂ : TCong T} (h : ∀ a b, c₁.rel a b ↔ c₂.rel a b) :
    c₁ = c₂ := by
  obtain ⟨r₁, _, _, _, _, _, _, _, _⟩ := c₁
  obtain ⟨r₂, _, _, _, _, _, _, _, _⟩ := c₂
  have hr : r₁ = r₂ := funext fun a => funext fun b => propext (h a b)
  subst hr; rfl

/-- The **diagonal** (equality) congruence. -/
def diagonal (T : TOS R) : TCong T where
  rel := Eq
  rel_refl := fun _ => rfl
  rel_symm := Eq.symm
  rel_trans := Eq.trans
  rel_add := by intros; subst_vars; rfl
  rel_mul := by intros; subst_vars; rfl
  rel_tau := by intros; subst_vars; rfl
  rel_rho := by intros; subst_vars; rfl
  rel_oracle := by intros; subst_vars; rfl

/-- The **total** congruence. -/
def total (T : TOS R) : TCong T where
  rel := fun _ _ => True
  rel_refl := fun _ => trivial
  rel_symm := fun _ => trivial
  rel_trans := fun _ _ => trivial
  rel_add := by intros; trivial
  rel_mul := by intros; trivial
  rel_tau := by intros; trivial
  rel_rho := by intros; trivial
  rel_oracle := by intros; trivial

/-- The **intersection** (meet) of two temporal congruences. -/
def inf (c₁ c₂ : TCong T) : TCong T where
  rel a b := c₁.rel a b ∧ c₂.rel a b
  rel_refl := fun x => ⟨c₁.rel_refl x, c₂.rel_refl x⟩
  rel_symm := by intro _ _ h; exact ⟨c₁.rel_symm h.1, c₂.rel_symm h.2⟩
  rel_trans := by intro _ _ _ h₁ h₂; exact ⟨c₁.rel_trans h₁.1 h₂.1, c₂.rel_trans h₁.2 h₂.2⟩
  rel_add := by intro _ _ _ _ h₁ h₂; exact ⟨c₁.rel_add h₁.1 h₂.1, c₂.rel_add h₁.2 h₂.2⟩
  rel_mul := by intro _ _ _ _ h₁ h₂; exact ⟨c₁.rel_mul h₁.1 h₂.1, c₂.rel_mul h₁.2 h₂.2⟩
  rel_tau := by intro _ _ h; exact ⟨c₁.rel_tau h.1, c₂.rel_tau h.2⟩
  rel_rho := by intro _ _ h; exact ⟨c₁.rel_rho h.1, c₂.rel_rho h.2⟩
  rel_oracle := by intro o _ _ h; exact ⟨c₁.rel_oracle o h.1, c₂.rel_oracle o h.2⟩

instance : LE (TCong T) where
  le c₁ c₂ := ∀ a b, c₁.rel a b → c₂.rel a b

instance : Preorder (TCong T) where
  le := (· ≤ ·)
  le_refl _ _ _ h := h
  le_trans _ _ _ h₁ h₂ _ _ h := h₂ _ _ (h₁ _ _ h)

def IsProper (c : TCong T) : Prop :=
  ∃ x y : R, ¬ c.rel x y

/-- A congruence is **prime** if proper and meet-irreducible. -/
def IsPrime (c : TCong T) : Prop :=
  c.IsProper ∧
  ∀ c₁ c₂ : TCong T,
    (∀ a b, c.rel a b ↔ (c₁.rel a b ∧ c₂.rel a b)) →
    (∀ a b, c.rel a b ↔ c₁.rel a b) ∨ (∀ a b, c.rel a b ↔ c₂.rel a b)

theorem diagonal_le (c : TCong T) : diagonal T ≤ c :=
  fun _ b h => h ▸ c.rel_refl b

theorem le_total (c : TCong T) : c ≤ total T :=
  fun _ _ _ => trivial

theorem inf_le_left (c₁ c₂ : TCong T) : inf c₁ c₂ ≤ c₁ :=
  fun _ _ h => h.1

theorem inf_le_right (c₁ c₂ : TCong T) : inf c₁ c₂ ≤ c₂ :=
  fun _ _ h => h.2

theorem le_inf {c c₁ c₂ : TCong T} (h₁ : c ≤ c₁) (h₂ : c ≤ c₂) :
    c ≤ inf c₁ c₂ :=
  fun a b h => ⟨h₁ a b h, h₂ a b h⟩

end TCong

/-! ## Canonical Evaluation -/

def eval (c : TCong T) (x : R) : Quotient c.toSetoid :=
  Quotient.mk c.toSetoid x

def canonicalEval (T : TOS R) (x : R) : (c : TCong T) → Quotient c.toSetoid :=
  fun c => eval c x

/-- **Representation Theorem**: The canonical evaluation map is injective. -/
theorem canonicalEval_injective :
    Function.Injective (canonicalEval T) := by
  intro x y h
  exact Quotient.exact (congr_fun h (TCong.diagonal T))

/-! ## Orbit Periodicity -/

/-
On a finite type, every orbit is eventually periodic.
-/
theorem orbit_eventually_periodic {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ N p : ℕ, 0 < p ∧ f^[N + p] x = f^[N] x := by
  -- By the pigeonhole principle, since there are only finitely many possible values for $f^[n] x$, there must exist $m < n$ such that $f^[m] x = f^[n] x$.
  obtain ⟨m, n, hmn, h_eq⟩ : ∃ m n : ℕ, m < n ∧ f^[m] x = f^[n] x := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun m n hmn => le_antisymm ( not_lt.1 fun contra => h _ _ contra hmn.symm ) ( not_lt.1 fun contra => h _ _ contra hmn ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  exact ⟨ m, n - m, Nat.sub_pos_of_lt hmn, by rw [ add_tsub_cancel_of_le hmn.le, h_eq ] ⟩

/-
Bijections on finite types have purely periodic orbits.
-/
theorem bijection_orbit_periodic {α : Type*} [Fintype α] [DecidableEq α]
    (f : α ≃ α) (x : α) :
    ∃ p : ℕ, 0 < p ∧ f^[p] x = x := by
  exact ⟨ orderOf f, orderOf_pos _, by simp +decide [ pow_orderOf_eq_one ] ⟩

/-
Temporal orbits are periodic modulo any congruence.
-/
theorem temporal_orbit_periodic [Fintype R] [DecidableEq R]
    (T : TOS R) (c : TCong T) (x : R) :
    ∃ p : ℕ, 0 < p ∧ c.rel ((⇑T.tau)^[p] x) x := by
  obtain ⟨ p, hp, hp' ⟩ := bijection_orbit_periodic T.tau.toEquiv x;
  exact ⟨ p, hp, hp'.symm ▸ c.rel_refl x ⟩

/-! ## Orbit Certificates -/

structure OrbitCertificate (T : TOS R) (x : R) where
  period : ℕ
  period_pos : 0 < period
  cong : TCong T
  periodic : cong.rel ((⇑T.tau)^[period] x) x

theorem exists_orbit_certificate [Fintype R] [DecidableEq R]
    (T : TOS R) (c : TCong T) (x : R) :
    ∃ cert : OrbitCertificate T x, cert.cong = c := by
  obtain ⟨p, hp, hper⟩ := temporal_orbit_periodic T c x
  exact ⟨⟨p, hp, c, hper⟩, rfl⟩

/-! ## Separation -/

inductive SeparationResult (T : TOS R) (x y : R) where
  | separated (c : TCong T) (hxy : ¬ c.rel x y)
  | identified (h : x = y)

def decideSeparation [DecidableEq R] (T : TOS R) (x y : R) :
    SeparationResult T x y :=
  if h : x = y then .identified h
  else .separated (TCong.diagonal T) h

/-! ## Prime Temporal Separation -/

section PrimeSeparation
variable [Fintype R] [DecidableEq R]

/-
**Prime Temporal Separation**: Distinct elements are separated by prime congruences.
-/
omit [DecidableEq R] in
theorem prime_temporal_separation (T : TOS R) (x y : R) (hne : x ≠ y) :
    ∃ c : TCong T, c.IsPrime ∧ ¬ c.rel x y := by
  -- By Zorn's lemma, there exists a maximal element $c₀$ in the set of congruences that do not identify $x$ and $y$.
  obtain ⟨c₀, hc₀⟩ : ∃ c₀ : TCong T, ¬c₀.rel x y ∧ ∀ c : TCong T, ¬c.rel x y → c₀ ≤ c → c₀ = c := by
    have h_nonempty : ∃ c : TCong T, ¬c.rel x y := by
      exact ⟨ TCong.diagonal T, by simpa using hne ⟩;
    have h_max : ∀ (S : Set (TCong T)), S.Nonempty → BddAbove S → ∃ c₀ ∈ S, ∀ c ∈ S, c₀ ≤ c → c₀ = c := by
      intros S hS_nonempty hS_bdd_above
      obtain ⟨c₀, hc₀⟩ : ∃ c₀ ∈ S, ∀ c ∈ S, c₀.rel ≤ c.rel → c₀.rel = c.rel := by
        have h_finite : Set.Finite (Set.image (fun c : TCong T => c.rel) S) := by
          exact Set.toFinite _;
        have := h_finite.toFinset.exists_maximal;
        simp_all +decide [ Maximal ];
        exact ⟨ this.choose, this.choose_spec.1, fun c hc h => le_antisymm h ( this.choose_spec.2 c hc h ) ⟩;
      exact ⟨ c₀, hc₀.1, fun c hc h => TCong.ext' fun a b => by simpa using congr_fun ( congr_fun ( hc₀.2 c hc h ) a ) b ⟩;
    exact h_max _ ⟨ _, h_nonempty.choose_spec ⟩ ⟨ TCong.total T, fun c hc => TCong.le_total c ⟩;
  refine' ⟨ c₀, ⟨ ⟨ x, y, hc₀.1 ⟩, fun c₁ c₂ hc => _ ⟩, hc₀.1 ⟩;
  by_cases h₁ : c₁.rel x y <;> by_cases h₂ : c₂.rel x y <;> simp_all +decide;
  · contrapose! hc₀;
    refine' ⟨ c₂, h₂, _, _ ⟩;
    · exact fun a b hab => hc a b |>.1 hab |>.2;
    · grind;
  · specialize hc₀ c₁ h₁;
    specialize hc₀ ( fun a b hab => hc a b |>.1 hab |>.1 ) ; aesop;
  · contrapose! hc₀;
    refine' ⟨ c₁, h₁, _, _ ⟩;
    · exact fun a b hab => hc a b |>.1 hab |>.1;
    · grind

/-- **Spectral Representation**: Agreement on all prime quotients implies equality. -/
theorem spectralEval_separates (T : TOS R) (x y : R)
    (h : ∀ c : TCong T, c.IsPrime → c.rel x y) : x = y := by
  by_contra hne
  obtain ⟨c, hprime, hsep⟩ := prime_temporal_separation T x y hne
  exact hsep (h c hprime)

end PrimeSeparation

/-! ## Finite Temporal Priestley Frame -/

structure FiniteTemporalFrame where
  X : Type*
  [instFintype : Fintype X]
  [instDecEq : DecidableEq X]
  [instPartialOrder : PartialOrder X]
  next : X ≃o X
  rev : X ≃ X
  rev_invol : ∀ x, rev (rev x) = x
  rev_next : ∀ x, rev (next x) = next.symm (rev x)

/-! ## TOS Morphisms -/

structure TOSHom {R S : Type*} [Semiring R] [Semiring S]
    (T₁ : TOS R) (T₂ : TOS S) extends R →+* S where
  comm_tau : ∀ x, toRingHom (T₁.tau x) = T₂.tau (toRingHom x)
  comm_rho : ∀ x, toRingHom (T₁.rho x) = T₂.rho (toRingHom x)

end TemporalSpectrum
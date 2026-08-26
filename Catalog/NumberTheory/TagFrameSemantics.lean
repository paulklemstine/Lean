import Algebra.ReflectionDepthSpectrum
import Novelty.TransferPreorderRealization

/-!
# Tag-indexed Kripke frames with a valuation: the common home of `capC` and `valSys`

The catalog contains two orthogonal generalisations of the standard Kripke model on
`(ℕ, <)` used in `Novelty.ArithmetizedQFTReflection`:

* `satC c` (`Novelty.ConsistencyTransferSharpness`) makes the *accessibility* relation
  tag-sensitive — tag `i` sees `n < m` only while `m ≤ c i` — but keeps every atom
  true at every world;
* `satV V` (`Algebra.ReflectionDepthSpectrum`) keeps the tag-independent frame `<` but
  interprets the atoms by an arbitrary *valuation* `V`.

This file builds the common refinement, and in fact a considerably more general
object: a **tag-indexed frame** is an arbitrary family of Boolean relations
`R : ℕ → ℕ → ℕ → Bool` (`R i m n` = "at tag `i` the world `m` sees the world `n`"),
used only below the diagonal (`n < m`, which is enforced by the semantics), together
with a valuation `V`.  Every such frame that is *transitive* validates all of GL
(`isGL_frameSys`), and truncating validity to the worlds `0, …, N` gives a consistent
GL theory `frameSys R V N` (`consistent_frameSys`).

Two general tools are proved here and used repeatedly downstream:

* `provable_frameSys_box_iff` — the theory proves `□_i a` iff `a` is true throughout
  the **image** `Im_i = {n | ∃ m ≤ N, n < m ∧ R i m n}` of the tag's accessibility
  relation.  Hence the depth-restricted reflection rule `DepthReflection` of
  `Combinatorics.BoxDepthReflection` is exactly the statement that low box depth
  cannot distinguish the image of tag `i` from the whole model;
* `satF_congr_of_approx` — an Ehrenfeucht–Fraïssé / bounded-bisimulation transfer
  lemma: a symmetric family `E k` of relations with the back-and-forth property
  identifies the truth values of all formulas of box depth `≤ k`.  This is the
  uniform replacement for the ad hoc locality lemmas `sat_eq_of_boxDepth_le` and
  `satV_blockVal_local`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): all the locality lemmas of the catalog are shadows of one
  bounded-bisimulation principle, and all the "height" computations are shadows of one
  image computation `provable_frameSys_box_iff`.
Experiment (Stage 2): both were formalised for arbitrary tag-indexed frames; `satCV`
  (the conjectured common refinement) and the window frames of
  `NumberTheory.TagReflectionDepthRigidity` are instances.
Analysis (Stage 3): transitivity of each `R i` is the only hypothesis needed for GL —
  converse well-foundedness is automatic because the semantics only ever looks at
  worlds `n < m`.
Critique (Stage 4): the frame `R` is Boolean, so no decidability side conditions are
  needed and every finite instance can be evaluated by `decide`.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Frame semantics -/

/-- **Tag-indexed Kripke satisfaction with a valuation.**  The world `m` sees the world
`n` at tag `i` iff `n < m` and `R i m n`; the atoms are interpreted by `V`. -/
def satF (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) : ℕ → Form → Bool
  | _, bot => false
  | m, atom p => V m p
  | m, imp a b => (!(satF R V m a)) || satF R V m b
  | m, box i a => (List.range m).all (fun n => !(R i m n) || satF R V n a)

variable {R : ℕ → ℕ → ℕ → Bool} {V : ℕ → ℕ → Bool}

@[simp] theorem satF_bot (m : ℕ) : satF R V m bot = false := rfl

@[simp] theorem satF_atom (m p : ℕ) : satF R V m (atom p) = V m p := rfl

theorem satF_imp (m : ℕ) (a b : Form) :
    satF R V m (imp a b) = true ↔ (satF R V m a = true → satF R V m b = true) := by
  simp only [satF]; cases satF R V m a <;> cases satF R V m b <;> simp

theorem satF_box (m i : ℕ) (a : Form) :
    satF R V m (box i a) = true ↔
      ∀ n, n < m → R i m n = true → satF R V n a = true := by
  simp only [satF, List.all_eq_true, List.mem_range]
  constructor
  · intro h n hn hR
    have := h n hn
    simpa [hR] using this
  · intro h n hn
    by_cases hR : R i m n = true
    · simp [hR, h n hn hR]
    · simp only [Bool.not_eq_true] at hR
      simp [hR]

/-- **Transitivity of the tag's accessibility relation** is the only hypothesis needed
for the `4` axiom, and hence for GL. -/
def FrameTrans (R : ℕ → ℕ → ℕ → Bool) (i : ℕ) : Prop :=
  ∀ m n k : ℕ, k < n → n < m → R i m n = true → R i n k = true → R i m k = true

/-- Converse well-foundedness is automatic — the semantics only inspects worlds
strictly below the current one — and together with transitivity it is the engine
behind the Löb axiom: if `□_i a → a` holds at every world seen by `m`, then `a` holds
at every world seen by `m`. -/
theorem satF_loeb_engine {i : ℕ} (htr : FrameTrans R i) (a : Form) (m : ℕ)
    (h : ∀ n, n < m → R i m n = true → satF R V n (imp (box i a) a) = true) :
    ∀ n, n < m → R i m n = true → satF R V n a = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn hR
    have hstep := h n hn hR
    rw [satF_imp] at hstep
    refine hstep ?_
    rw [satF_box]
    intro k hk hR'
    exact ih k hk (hk.trans hn) (htr m n k hk hn hR hR')

/-! ## §2. The truncated theory of a frame -/

/-- The theory of the frame `(R, V)` truncated to the worlds `0, …, N`. -/
def frameSys (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (N : ℕ) : ProofSys Form where
  Proof := { a : Form // ∀ m ≤ N, satF R V m a = true }
  concl := Subtype.val
  size := fun _ => 0

theorem provable_frameSys (N : ℕ) (a : Form) :
    Provable (frameSys R V N) a ↔ ∀ m ≤ N, satF R V m a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **Every transitive tag-indexed frame yields a GL theory.** -/
theorem isGL_frameSys (N i : ℕ) (htr : FrameTrans R i) : IsGLTheory i (frameSys R V N) := by
  constructor
  · intro a b hab ha
    rw [provable_frameSys] at *
    intro m hm
    exact (satF_imp m a b).1 (hab m hm) (ha m hm)
  · intro a ha
    rw [provable_frameSys] at *
    intro m _
    rw [satF_box]
    intro n hn _
    exact ha n (by omega)
  · intro a ha
    rw [provable_frameSys]
    intro m _
    exact ha (satF R V m) rfl (fun _ _ => rfl)
  · intro a b
    rw [provable_frameSys]
    intro m _
    rw [satF_imp]; intro hab
    rw [satF_imp]; intro ha
    rw [satF_box] at hab ha ⊢
    intro n hn hR
    exact (satF_imp n a b).1 (hab n hn hR) (ha n hn hR)
  · intro a
    rw [provable_frameSys]
    intro m _
    rw [satF_imp]; intro h
    rw [satF_box] at h ⊢
    intro n hn hR
    rw [satF_box]
    intro k hk hR'
    exact h k (hk.trans hn) (htr m n k hk hn hR hR')
  · intro a
    rw [provable_frameSys]
    intro m _
    rw [satF_imp]; intro h
    rw [satF_box] at h ⊢
    exact satF_loeb_engine htr a m h

/-- Every truncated frame theory is consistent: `⊥` fails at the root world. -/
theorem consistent_frameSys (N : ℕ) : Consistent (frameSys R V N) := by
  intro h
  rw [provable_frameSys] at h
  have := h 0 (Nat.zero_le N)
  simp at this

/-! ## §3. Provable boxes are truth on the image -/

/-- The **image** of the accessibility relation of tag `i` inside the truncation
`0, …, N`: the worlds that are seen by some world of the model. -/
def FrameImage (R : ℕ → ℕ → ℕ → Bool) (N i n : ℕ) : Prop :=
  ∃ m ≤ N, n < m ∧ R i m n = true

/-- **`□_i a` is provable iff `a` is true throughout the image of tag `i`.**  So the
depth-restricted reflection rule for tag `i` says exactly that formulas of small box
depth cannot separate the image of tag `i` from the whole truncated model. -/
theorem provable_frameSys_box_iff (N i : ℕ) (a : Form) :
    Provable (frameSys R V N) (box i a) ↔
      ∀ n, FrameImage R N i n → satF R V n a = true := by
  rw [provable_frameSys]
  constructor
  · rintro h n ⟨m, hm, hnm, hR⟩
    exact (satF_box m i a).1 (h m hm) n hnm hR
  · intro h m hm
    rw [satF_box]
    intro n hn hR
    exact h n ⟨m, hm, hn, hR⟩

/-! ## §4. A bounded-bisimulation transfer lemma -/

/-- **Bounded bisimulation transfers truth of formulas of bounded box depth.**  If
`E k` is a symmetric family of relations between worlds such that `E k`-related worlds
agree on all atoms, and every `R j`-successor of an `E (k+1)`-related world is matched
by an `E k`-related `R j`-successor of the other, then `E k`-related worlds satisfy the
same formulas of box depth `≤ k`. -/
theorem satF_congr_of_approx (E : ℕ → ℕ → ℕ → Prop)
    (hatom : ∀ k m n, E k m n → ∀ p, V m p = V n p)
    (hsymm : ∀ k m n, E k m n → E k n m)
    (hstep : ∀ k m n, E (k + 1) m n → ∀ j m', m' < m → R j m m' = true →
      ∃ n', n' < n ∧ R j n n' = true ∧ E k m' n') :
    ∀ (a : Form) (k m n : ℕ), boxDepth a ≤ k → E k m n → satF R V m a = satF R V n a := by
  intro a
  induction a with
  | bot => intro _ _ _ _ _; rfl
  | atom p => intro k m n _ hE; simpa using hatom k m n hE p
  | imp p q ihp ihq =>
      intro k m n hk hE
      simp only [boxDepth, max_le_iff] at hk
      simp only [satF, ihp k m n hk.1 hE, ihq k m n hk.2 hE]
  | box j b ih =>
      intro k m n hk hE
      simp only [boxDepth_box] at hk
      obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
      have hb : boxDepth b ≤ k' := by omega
      rw [Bool.eq_iff_iff, satF_box, satF_box]
      constructor
      · intro hm n' hn' hR'
        obtain ⟨m', hm', hRm', hE'⟩ :=
          hstep k' n m (hsymm _ _ _ hE) j n' hn' hR'
        rw [← ih k' m' n' hb (hsymm _ _ _ hE')]
        exact hm m' hm' hRm'
      · intro hn m' hm' hRm'
        obtain ⟨n', hn', hRn', hE'⟩ := hstep k' m n hE j m' hm' hRm'
        rw [ih k' m' n' hb hE']
        exact hn n' hn' hRn'

/-- **Box-free formulas only see the valuation.**  A formula of box depth `0` has the
same truth value at two worlds carrying the same atoms. -/
theorem satF_congr_of_boxDepth_zero {m n : ℕ} (hV : ∀ p, V m p = V n p) :
    ∀ a : Form, boxDepth a = 0 → satF R V m a = satF R V n a := by
  intro a
  induction a with
  | bot => intro _; rfl
  | atom p => intro _; simpa using hV p
  | imp p q ihp ihq =>
      intro h
      simp only [boxDepth, Nat.max_eq_zero_iff] at h
      simp only [satF, ihp h.1, ihq h.2]
  | box j b _ => intro h; simp [boxDepth_box] at h

/-! ## §5. Iterated boxed falsum in a frame -/

/-- Monotonicity of the iterated boxed falsum in the iteration count: if a world has no
`R i`-chain of length `k`, it has none of length `k + 1` either. -/
theorem satF_boxPow_bot_mono (i : ℕ) :
    ∀ (k m : ℕ), satF R V m (boxPow i k bot) = true →
      satF R V m (boxPow i (k + 1) bot) = true := by
  intro k
  induction k with
  | zero => intro m h; simp [boxPow] at h
  | succ k ih =>
      intro m h
      rw [boxPow, satF_box] at h ⊢
      intro n hn hR
      exact ih n (h n hn hR)

/-- Monotonicity in the iteration count, in the form used for the height spectra. -/
theorem satF_boxPow_bot_mono_le (i : ℕ) {k l m : ℕ} (hkl : k ≤ l)
    (h : satF R V m (boxPow i k bot) = true) :
    satF R V m (boxPow i l bot) = true := by
  obtain ⟨t, rfl⟩ : ∃ t, l = k + t := ⟨l - k, by omega⟩
  clear hkl
  induction t with
  | zero => simpa using h
  | succ t ih => exact satF_boxPow_bot_mono i (k + t) m ih

/-! ## §6. The reflection depth is monotone in the accessibility image -/

/-- **The image principle.**  In any tag-indexed frame theory the depth-restricted
reflection rules of a tag depend on the tag *only through the image of its
accessibility relation*, and they get harder to satisfy as the image grows: a formula
witnessing the failure of the rule for a tag with the larger image (true on that image,
but unprovable) witnesses it for every tag with a smaller image as well.

This is the abstract reason for the rigidity phenomenon of
`NumberTheory.TagReflectionDepthRigidity`: in a frame whose tag images are *nested*
— which is the case for the tag-truncated frames `capC`, whose images are the initial
segments `[0, min N (c i))` — the reflection depths are forced to be monotone in the
heights, and equal images force equal reflection depths.  Escaping the constraint
requires *incomparable* images. -/
theorem depthReflection_frameSys_of_image_subset {N i j d : ℕ}
    (hsub : ∀ n, FrameImage R N i n → FrameImage R N j n)
    (h : DepthReflection d i (frameSys R V N)) :
    DepthReflection d j (frameSys R V N) := by
  intro a hdep hbox
  refine h a hdep ?_
  rw [provable_frameSys_box_iff] at hbox ⊢
  exact fun n hn => hbox n (hsub n hn)

/-- **Equal images, equal reflection depths.**  Two tags with the same accessibility
image satisfy literally the same depth-restricted reflection rules, whatever the
valuation. -/
theorem depthReflection_frameSys_congr_of_image_eq {N i j : ℕ}
    (heq : ∀ n, FrameImage R N i n ↔ FrameImage R N j n) (d : ℕ) :
    DepthReflection d i (frameSys R V N) ↔ DepthReflection d j (frameSys R V N) :=
  ⟨depthReflection_frameSys_of_image_subset (fun n hn => (heq n).1 hn),
    depthReflection_frameSys_of_image_subset (fun n hn => (heq n).2 hn)⟩

/-- **Differing reflection depths force incomparable images.**  The sharp converse of
the image principle: if a tag `i` satisfies a depth-restricted reflection rule that a
tag `j` violates, then the image of `i` is *not* contained in the image of `j`.  So any
construction decoupling the reflection depths of two tags must give them incomparable
accessibility images. -/
theorem frameImage_not_subset_of_depthReflection_ne {N i j d : ℕ}
    (h1 : DepthReflection d i (frameSys R V N))
    (h2 : ¬ DepthReflection d j (frameSys R V N)) :
    ¬ (∀ n, FrameImage R N i n → FrameImage R N j n) :=
  fun hsub => h2 (depthReflection_frameSys_of_image_subset hsub h1)

end PhysicsConsistency
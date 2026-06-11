/-
  Cryptographic Hash Functions: Collision Resistance via Merkle-Damgård

  We formalize the Merkle-Damgård construction and prove that it preserves
  collision resistance of the underlying compression function. Specifically:

  1. If the compression function f : α × β → α is injective (no collisions),
     then the iterated Merkle-Damgård hash is injective on same-length messages.
  2. Contrapositively, any collision in the Merkle-Damgård hash on same-length
     messages implies a collision in the compression function.
  3. A constructive convergence lemma: if two different initial states converge
     under the same message sequence, we can extract an explicit compression collision.

  These results formalize the classical cryptographic reduction that underpins
  the security of hash functions like SHA-256, MD5, etc.
-/

import Mathlib

namespace CryptoHash

-- !-- Lab Notebook: Project Setup -- !--
-- !-- Hypothesis: Merkle-Damgård collision resistance can be formalized as
--     pure list/function theory without probabilistic reasoning -- !--
-- !-- Result: Yes — the reduction is purely combinatorial -- !--
-- !-- Insight: The key abstraction is foldl joint injectivity, which captures
--     the essence of collision resistance preservation -- !--
-- !-- End Lab Notebook -- !--

/-- The Merkle-Damgård construction: iteratively apply a compression function
    `f : α → β → α` starting from an initialization vector `iv`, processing
    each block of the message in sequence. -/
def merkleDamgard (f : α → β → α) (iv : α) (msg : List β) : α :=
  msg.foldl f iv

/-- Merkle-Damgård of an empty message returns the IV. -/
@[simp]
theorem merkleDamgard_nil (f : α → β → α) (iv : α) :
    merkleDamgard f iv [] = iv := rfl

/-- Merkle-Damgård processes one block by applying the compression function. -/
@[simp]
theorem merkleDamgard_cons (f : α → β → α) (iv : α) (b : β) (msg : List β) :
    merkleDamgard f iv (b :: msg) = merkleDamgard f (f iv b) msg := rfl

-- !-- comment: The append theorem captures the "domain extension" property:
--     processing m₁ ++ m₂ is the same as processing m₂ starting from
--     the hash of m₁. This is the structural core of Merkle-Damgård. -- !--

/-- Merkle-Damgård distributes over message concatenation: the hash of
    `m₁ ++ m₂` equals processing `m₂` with the hash of `m₁` as IV. -/
theorem merkleDamgard_append (f : α → β → α) (iv : α) (m₁ m₂ : List β) :
    merkleDamgard f iv (m₁ ++ m₂) = merkleDamgard f (merkleDamgard f iv m₁) m₂ := by
  simp [merkleDamgard, List.foldl_append]

/-! ## Core Injectivity Theorem -/

/-
!-- Lab Notebook: foldl_joint_injective -- !--
!-- Hypothesis: If f is injective as a pair function, then foldl f is jointly
injective in (initial value, list) for same-length lists -- !--
!-- Result: Proved by induction on l₁ generalizing l₂ a₁ a₂ -- !--
!-- Insight: The proof has a beautiful recursive structure: IH gives equality
of intermediate states, then injectivity of f peels off one layer -- !--
!-- Failure analysis: First attempt without generalizing a₁ a₂ failed because
the IH was too weak -- !--
!-- End Lab Notebook -- !--

!-- comment: Proof sketch for foldl_joint_injective:
By induction on l₁ generalizing l₂, a₁, a₂.
Base: l₂ = [] by length, so a₁ = a₂ trivially.
Step: l₁ = h₁::t₁, l₂ = h₂::t₂. foldl f (f a₁ h₁) t₁ = foldl f (f a₂ h₂) t₂.
IH gives f a₁ h₁ = f a₂ h₂ ∧ t₁ = t₂. Injectivity of f gives a₁ = a₂ ∧ h₁ = h₂. -- !--

**Joint injectivity of foldl**: If the compression function `f` is injective
    (viewed as a function from pairs `α × β → α`), then `List.foldl f` is jointly
    injective in both the initial accumulator and the list, provided the lists
    have equal length.

    This is the key algebraic fact underlying Merkle-Damgård collision resistance.
-/
theorem foldl_joint_injective {α β : Type*} {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    {l₁ l₂ : List β} {a₁ a₂ : α}
    (hlen : l₁.length = l₂.length)
    (heq : l₁.foldl f a₁ = l₂.foldl f a₂) :
    a₁ = a₂ ∧ l₁ = l₂ := by
  induction' l₁ with l₁_head l₁_tail l₁_ih generalizing l₂ a₁ a₂;
  · cases l₂ <;> aesop;
  · induction' l₂ with l₂_head l₂_tail l₂_ih generalizing a₁ a₂;
    · cases hlen;
    · specialize @l₁_ih l₂_tail ( f a₁ l₁_head ) ( f a₂ l₂_head ) ; simp_all +decide [ List.foldl ];
      have := @hf ( a₁, l₁_head ) ( a₂, l₂_head ) ; aesop;

/-! ## Collision Resistance Preservation -/

/-
!-- comment: Proof sketch for compress_injective_md_injective:
Direct application of foldl_joint_injective with a₁ = a₂ = iv.
The joint injectivity gives iv = iv (trivial) and m₁ = m₂. -- !--

**Merkle-Damgård preserves injectivity**: If the compression function is
    injective, then the Merkle-Damgård hash is injective on messages of equal
    length. This is the positive form of collision resistance preservation.
-/
theorem compress_injective_md_injective {α β : Type*} {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    (iv : α) {m₁ m₂ : List β}
    (hlen : m₁.length = m₂.length)
    (heq : merkleDamgard f iv m₁ = merkleDamgard f iv m₂) :
    m₁ = m₂ := by
  apply (foldl_joint_injective hf hlen heq).right

/-
!-- Lab Notebook: md_collision_implies_compress_collision -- !--
!-- Hypothesis: A collision in MD implies a collision in the compression function -- !--
!-- Result: Proved as contrapositive of compress_injective_md_injective -- !--
!-- Insight: The contrapositive formulation avoids needing to constructively
extract the collision location — classical logic handles the existential -- !--
!-- Failure analysis: N/A — clean proof via by_contra -- !--
!-- End Lab Notebook -- !--

!-- comment: Proof sketch for md_collision_implies_compress_collision:
By contrapositive. Assume f has no collisions (i.e., f is injective as pairs).
Then by compress_injective_md_injective, m₁ = m₂, contradicting hne. -- !--

**Merkle-Damgård collision reduction** (the main security theorem):
    If two distinct messages of equal length produce the same Merkle-Damgård hash,
    then the compression function has a collision — i.e., there exist distinct
    input pairs `(a₁, b₁) ≠ (a₂, b₂)` with `f a₁ b₁ = f a₂ b₂`.

    This is the fundamental reduction that lets us base hash function security
    on the collision resistance of a fixed-size compression function.
-/
theorem md_collision_implies_compress_collision {α β : Type*}
    (f : α → β → α) (iv : α) {m₁ m₂ : List β}
    (hlen : m₁.length = m₂.length)
    (hne : m₁ ≠ m₂)
    (hcol : merkleDamgard f iv m₁ = merkleDamgard f iv m₂) :
    ∃ (p₁ p₂ : α × β), p₁ ≠ p₂ ∧ Function.uncurry f p₁ = Function.uncurry f p₂ := by
  by_contra h_inj
  push_neg at h_inj;
  exact hne ( compress_injective_md_injective ( fun p₁ p₂ h => Classical.not_not.1 fun hne => h_inj p₁ p₂ hne h ) iv hlen hcol )

/-! ## Constructive Convergence -/

/-
!-- Lab Notebook: foldl_convergence -- !--
!-- Hypothesis: When two different initial states converge under foldl with
the same list, there must be a specific step where different states
and the same block input produce the same output -- !--
!-- Result: Proved by induction on l with case split on f a₁ (head) vs f a₂ (head) -- !--
!-- Insight: This gives a CONSTRUCTIVE collision extraction, unlike the
contrapositive argument. The collision always has the same block input. -- !--
!-- Failure analysis: N/A -- !--
!-- End Lab Notebook -- !--

!-- comment: Proof sketch for foldl_convergence:
By induction on l. Base case l = [] gives a₁ = a₂, contradiction.
Inductive case l = h :: t: if f a₁ h = f a₂ h, done (collision found).
Otherwise f a₁ h ≠ f a₂ h, and foldl f (f a₁ h) t = foldl f (f a₂ h) t,
so IH applies with the new states. -- !--

**Constructive convergence lemma**: If two different initial states produce
    the same output when `foldl`-ing with the same message, then there exists
    a specific compression step where two different states and the same block
    input produce the same output.

    This gives a stronger, constructive form of collision extraction compared
    to the contrapositive argument. Note that the extracted collision has
    `b₁ = b₂` (same block input), which is a special form of collision
    where only the chaining value differs.
-/
theorem foldl_convergence {α β : Type*} [DecidableEq α]
    (f : α → β → α) {a₁ a₂ : α} (l : List β)
    (hne : a₁ ≠ a₂) (heq : l.foldl f a₁ = l.foldl f a₂) :
    ∃ (s₁ s₂ : α) (b : β), s₁ ≠ s₂ ∧ f s₁ b = f s₂ b := by
  induction' l with h t ih generalizing a₁ a₂;
  · aesop;
  · grind +ring

/-! ## Generalization: Variable-length collision resistance -/

-- !-- Lab Notebook: Generalization attempt -- !--
-- !-- Hypothesis: MD collision resistance extends to variable-length messages
--     with Merkle-Damgård strengthening (length padding) -- !--
-- !-- Result: Stated as conjecture — requires formalizing padding schemes -- !--
-- !-- Insight: Without length padding, MD is NOT collision resistant on
--     variable-length messages due to length extension attacks -- !--
-- !-- End Lab Notebook -- !--

/-- **Length extension vulnerability** (boundary case): Without padding,
    Merkle-Damgård is vulnerable to length extension. Specifically,
    if we know `merkleDamgard f iv m₁ = h`, then for any suffix `s`,
    `merkleDamgard f iv (m₁ ++ s) = merkleDamgard f h s`. An attacker
    can compute the hash of `m₁ ++ s` without knowing `m₁`. -/
theorem length_extension_property (f : α → β → α) (iv : α) (m₁ s : List β) :
    merkleDamgard f iv (m₁ ++ s) = merkleDamgard f (merkleDamgard f iv m₁) s :=
  merkleDamgard_append f iv m₁ s

/-- **Conjecture (variable-length collision resistance with padding)**:
    With Merkle-Damgård strengthening (appending the message length),
    collision resistance extends to variable-length messages.

    This requires formalizing a padding function and showing that
    length-different messages always differ after padding. -/
def mdStrengthen (f : α → β → α) (pad : List β → List β) (iv : α) (msg : List β) : α :=
  merkleDamgard f iv (pad msg)

/-
If the padding function is injective (e.g., appending message length)
    and the compression function is injective, then the strengthened MD
    construction is injective on all messages (not just same-length).
-/
theorem md_strengthen_injective {α β : Type*} {f : α → β → α} {pad : List β → List β}
    (hf : Function.Injective (Function.uncurry f))
    (hpad : Function.Injective pad)
    (hpad_len : ∀ m₁ m₂, (pad m₁).length = (pad m₂).length)
    (iv : α) {m₁ m₂ : List β}
    (heq : mdStrengthen f pad iv m₁ = mdStrengthen f pad iv m₂) :
    m₁ = m₂ := by
  have h_pad_eq : pad m₁ = pad m₂ := by
    -- Apply the compress_injective_md_injective theorem to conclude that pad m₁ = pad m₂.
    apply compress_injective_md_injective hf iv (hpad_len m₁ m₂) heq;
  exact hpad h_pad_eq

end CryptoHash
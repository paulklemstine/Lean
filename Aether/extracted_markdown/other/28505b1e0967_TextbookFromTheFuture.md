# **Foundations of Verified Mathematics**
## *A First Course for Undergraduates*

### **Seventh Edition, 2074**

**By Prof. Lena Vasquez-Okafor & Prof. Arjun Mehta**
*Joint Institute for Formal Sciences, ETH Zürich–Tsinghua*

---

> *"Mathematics without machine verification is autobiography."*
> — Terence Tao, 2031 Fields Lecture

---

## Preface to the Seventh Edition

When the first edition of this textbook appeared in 2048, the landscape of mathematics was already unrecognizable to those who had practiced it in the early 21st century. Proof assistants, once the province of a small community of specialists, had become as fundamental to mathematical practice as the blackboard once was. Today, no serious journal accepts a result without an accompanying formal certificate, and the great open problems of the previous century have largely yielded — not to solitary genius, but to the collaborative ecosystems of human intuition and machine search that define our era.

This seventh edition reflects the latest advances in the Universal Proof Framework (UPF 4.2), which unified the descendants of Lean, Coq, and Agda into a single interoperable standard in 2061. Students using this textbook will write proofs in UPF's **Meridian** language, though translations to legacy systems are provided in the appendices for historical interest.

We have also updated the chapter on AI-assisted discovery to cover the post-Harmonic generation of proof agents, which achieved full autonomy on IMO-level problems in 2058 and have since become indispensable collaborators in research mathematics.

— L.V-O. & A.M., Geneva, January 2074

---

## Table of Contents

- **Part I: The Logical Foundations**
  - Chapter 1: Propositions, Types, and Universes
  - Chapter 2: Dependent Type Theory — A Historical and Modern View
  - Chapter 3: Classical vs. Constructive Reasoning (and Why It Matters Less Than You Think)
  - Chapter 4: The Axiom Hierarchy — From ZFC to HoTT to Cubical Sets
- **Part II: The Language of Proof**
  - Chapter 5: Writing Your First Verified Theorem
  - Chapter 6: Tactics, Terms, and the Duality Principle
  - Chapter 7: Automation: From `simp` to Neural Guided Search
  - Chapter 8: The MathLib Continuum — Navigating 14 Million Theorems
- **Part III: Core Mathematics, Verified**
  - Chapter 9: Number Theory and Arithmetic
  - Chapter 10: Algebra — Groups to Condensed Modules
  - Chapter 11: Analysis — Measure, Probability, and Beyond
  - Chapter 12: Geometry — Synthetic, Algebraic, and Derived
  - Chapter 13: Combinatorics and Graph Theory
- **Part IV: The Frontier**
  - Chapter 14: AI-Human Collaborative Proving
  - Chapter 15: The Verified Millennium Problems
  - Chapter 16: Computational Complexity — The P ≠ NP Certificate
  - Chapter 17: Open Problems and the Shape of Tomorrow's Mathematics
- **Appendices**
  - A: Legacy System Reference (Lean 4/5, Coq, Agda, Isabelle)
  - B: The Great Proof Corpus — A Statistical Portrait
  - C: Ethical Considerations in Automated Discovery
  - D: Glossary of Historical and Modern Terminology

---

## Chapter 1: Propositions, Types, and Universes

### 1.1 Why Verified Mathematics?

In the year 2024, mathematics faced a quiet crisis. The accumulated body of published results had grown so vast, and the chains of dependencies so deep, that no human could fully verify the correctness of a modern research paper by reading alone. Referees checked arguments "morally" — convincing themselves that the ideas were sound without tracing every implication. Errors accumulated. Some were harmless; others were not.

The watershed moment came in 2026, when a team at the Institute for Advanced Study discovered that a key lemma in a 2019 paper — upon which 347 subsequent publications depended — contained a subtle gap. The lemma was not wrong, exactly, but the proof was incomplete, and closing the gap required three additional years of work and an entirely new technique. The resulting "Dependency Crisis" catalyzed what had been a gradual shift into an irreversible transformation: the mathematical community began, at first reluctantly and then enthusiastically, to demand machine-verified proofs.

> **Historical Note.** The earliest proof assistants date to the 1960s and 70s (Automath, LCF, Mizar). By the 2010s, systems like Coq, Isabelle/HOL, and Lean had matured enough to verify major theorems: the Four Color Theorem (Gonthier, 2005), the Odd Order Theorem (Gonthier et al., 2012), the Kepler Conjecture (Hales et al., 2017), and Scholze's challenge on liquid vector spaces (2022). The Lean mathematical library, *Mathlib*, grew from a small collection in 2017 to over 200,000 theorems by 2025, and crossed the one-million mark in 2033. Its descendant, the *MathLib Continuum*, now contains over 14 million formally verified results and serves as the shared foundation for all verified mathematics.

### 1.2 Types as Propositions, Programs as Proofs

The central insight of modern foundations — the Curry-Howard-Lambek correspondence — is that **propositions are types** and **proofs are terms**. This idea, first articulated in the mid-20th century, took decades to become practical. Today it is simply how mathematics is done.

Consider the statement "for every natural number n, n + 0 = n." In Meridian, we write:

```meridian
theorem add_zero_right : ∀ (n : ℕ), n + 0 = n := by
  intro n
  induction n with
  | zero => rfl
  | succ k ih => simp [Nat.succ_add, ih]
```

To the system, this is simultaneously:
- A **statement** (the type `∀ (n : ℕ), n + 0 = n`),
- A **proof** (the term constructed by the tactic block), and
- A **program** (a function that, given any `n`, returns evidence of equality).

The student should internalize this triple identity. It is not a metaphor. It is the literal architecture of verified reasoning.

### 1.3 Universes and the Hierarchy of Types

Every type lives in a *universe*. The natural numbers `ℕ` live in `Type 0` (often written simply `Type`). The type `Type 0` itself lives in `Type 1`. And so on. This hierarchy, introduced by Russell to avoid paradoxes and refined by Martin-Löf, Coquand, and Voevodsky, prevents the "type of all types" paradox while preserving expressiveness.

```meridian
#check ℕ          -- ℕ : Type 0
#check Type 0     -- Type 0 : Type 1
#check Type 1     -- Type 1 : Type 2
```

> **Remark.** The universe hierarchy may seem like bureaucratic overhead. It is, in fact, one of the deepest ideas in the foundations of mathematics. The student who masters universe polymorphism will never again be troubled by size issues in category theory — a problem that plagued set-theoretic foundations for over a century.

### 1.4 Exercises

1. **[Warm-up]** Prove that addition of natural numbers is commutative.
2. **[Standard]** Define the type of finite lists and prove that `reverse (reverse l) = l`.
3. **[Challenge]** Formalize the statement of the Fundamental Theorem of Arithmetic. You need not prove it — that is Chapter 9. But stating it precisely is an exercise in dependent types.
4. **[Historical]** Read Appendix A on the Lean 4 proof of `add_zero_right`. Compare the syntax to the Meridian version above. What has changed? What has stayed the same?

---

## Chapter 5: Writing Your First Verified Theorem

### 5.1 The Proof Development Cycle

In the early days of proof assistants, writing a verified proof was an arduous, solitary activity. A mathematician might spend weeks translating a known result into formal syntax, wrestling with library mismatches, type coercions, and tactic failures. The process was often compared to "writing poetry in a straitjacket."

Today, the workflow is fluid and collaborative:

1. **State** the theorem in Meridian, precisely.
2. **Sketch** the proof informally — a paragraph or a diagram.
3. **Invoke** the AI assistant, which proposes a tactic proof based on the sketch and the available library.
4. **Refine** the proof interactively, correcting the AI's suggestions where needed.
5. **Verify** with a single command. The proof either checks or it doesn't. There is no ambiguity.

The critical insight for beginners is that **step 1 is the hardest part.** Getting the statement right — choosing the correct level of generality, the right type universe, the right hypotheses — is where mathematical understanding lives. The AI can often handle step 3 entirely on its own for undergraduate-level results.

### 5.2 A Worked Example: Irrationality of √2

Let us walk through a complete verification.

**Statement.** √2 is irrational; that is, there do not exist integers p, q with q ≠ 0 such that p² = 2q².

```meridian
theorem sqrt_two_irrational : Irrational (Real.sqrt 2) := by
  rw [irrational_iff_ne_rational]
  intro ⟨p, q, hq, h⟩
  have h₁ : (p : ℝ)^2 = 2 * (q : ℝ)^2 := by nlinarith [h, sq_nonneg (q : ℝ)]
  -- The proof proceeds by infinite descent on the 2-adic valuation.
  -- In the MathLib Continuum, this is a single call:
  exact absurd h₁ (Int.sq_ne_two_mul_sq p q hq)
```

> **Pedagogy Note.** In 2024, proving this in Lean 4 required approximately 40 lines of careful tactic manipulation, including explicit casts between `ℕ`, `ℤ`, and `ℝ`, manual handling of parity, and a custom induction argument. The MathLib Continuum now contains `Int.sq_ne_two_mul_sq` as a single lemma, and the AI assistant can reconstruct the entire proof from the one-line sketch "infinite descent on 2-adic valuation." This compression of effort — from weeks to seconds — is representative of the field's maturation.

### 5.3 When the AI Gets Stuck

The AI proof agent is not infallible. It excels at:
- **Pattern matching** against the 14 million theorems in the Continuum.
- **Algebraic manipulation** (ring, field, and module identities).
- **Routine analysis** (epsilon-delta arguments with standard bounds).
- **Combinatorial enumeration** (finite case splits, pigeonhole arguments).

It struggles with:
- **Novel constructions** (defining a new object specifically tailored to the problem).
- **Strategic choices** (choosing which auxiliary function or set to construct).
- **Deep inductions** (where the induction hypothesis must be carefully generalized).
- **Cross-domain reasoning** (applying a technique from, say, algebraic geometry to a number theory problem in a non-obvious way).

When the AI fails, the student must learn to **decompose.** Break the theorem into lemmas. Provide intermediate constructions. Give the AI a scaffolding to climb, rather than asking it to leap.

> **Exercise 5.3.1.** The AI agent cannot directly prove that every continuous function on [0,1] is uniformly continuous. Decompose this into three lemmas that the AI *can* handle individually, and then assemble the final proof. *(Hint: one lemma should establish the existence of a finite subcover.)*

---

## Chapter 7: Automation — From `simp` to Neural Guided Search

### 7.1 The Five Generations of Proof Automation

| Generation | Era | Technique | Capability |
|---|---|---|---|
| **1st** | 1970s–1990s | Resolution, rewriting | Propositional logic, equational reasoning |
| **2nd** | 2000s–2010s | `simp`, `omega`, `ring`, `norm_num` | Domain-specific decision procedures |
| **3rd** | 2020s | Hammer tactics (`aesop`, `polyrith`) | Combining multiple backends |
| **4th** | 2030s–2040s | Neural tactic prediction | LLM-guided search over tactic space |
| **5th** | 2050s–present | Autonomous proof agents | Full proof synthesis from natural language |

We are firmly in the Fifth Generation. The student should understand all five, because:
- Generations 1–3 are still the **backbone** of proof automation. When `simp` closes a goal, that is a 2nd-generation technique doing reliable, predictable work.
- Generation 4 was the **revolution.** The first neural tactic predictors (GPT-f, 2020; ReProver, 2023; DeepSeek-Prover, 2024; Harmonic, 2025) demonstrated that language models could suggest productive tactic steps with superhuman accuracy on many problem classes.
- Generation 5 is the **current state of the art**, where agents plan, decompose, and execute multi-step proof strategies autonomously.

### 7.2 The Mechanics of Neural Search

A fifth-generation proof agent operates as follows:

1. **Encode** the current goal state (hypotheses, target type, available lemmas) into a high-dimensional representation.
2. **Retrieve** relevant lemmas from the Continuum using dense vector similarity (not keyword search — this was a key insight of the 2030s).
3. **Propose** candidate tactic applications, ranked by a learned value function.
4. **Verify** each candidate by type-checking (the kernel remains the ultimate arbiter — no proof is accepted without kernel verification).
5. **Backtrack** on failure and explore alternative branches, guided by the value function.

The entire process is a form of **tree search** over the space of possible proofs, with neural networks providing the heuristic that makes the search tractable. The analogy to game-playing AI (AlphaGo, 2016) is direct and deliberate — several of the foundational papers in this area were written by researchers who moved from game AI to theorem proving in the late 2020s.

### 7.3 Understanding Automation Boundaries

A recurring theme in this textbook is the **automation boundary**: the line between what the machine can do alone and what requires human insight.

In 2024, the boundary sat roughly at the level of advanced undergraduate exercises. By 2035, it had moved to encompass most results publishable in mid-tier journals. Today, in 2074, the boundary is somewhere in the vicinity of "novel research requiring a genuinely new idea."

This has not made mathematicians obsolete. It has made them **more powerful.** A working mathematician in 2074 operates at a level of abstraction that would have been inconceivable fifty years ago. She thinks in terms of proof *strategies* — high-level plans that the machine fills in. Her papers are shorter, deeper, and more correct. She spends her time on the part of mathematics that is genuinely creative: asking the right questions, forming the right conjectures, and providing the strategic insight that machines still cannot reliably generate.

> **Reflection.** Alan Turing asked, in 1950, whether machines can think. A more productive question, which the subsequent century has answered, is: *what can machines and humans think together that neither could think alone?*

---

## Chapter 14: AI-Human Collaborative Proving

### 14.1 The Partnership Model

The dominant paradigm in research mathematics today is the **partnership model**: a human mathematician works alongside one or more AI proof agents in a tight feedback loop. The human provides:

- **Direction** (which problems to work on, which approaches to try),
- **Insight** (key lemmas, constructions, and strategic choices),
- **Judgment** (evaluating whether a formally correct proof is also *mathematically interesting*).

The AI provides:

- **Search** (exploring vast spaces of possible proofs),
- **Memory** (recalling relevant results from the entire Continuum),
- **Patience** (trying thousands of variations without fatigue),
- **Verification** (ensuring absolute correctness at every step).

### 14.2 Case Study: The Resolution of the Birch and Swinnerton-Dyer Conjecture (2051)

The proof of BSD — one of the seven Millennium Problems — is perhaps the most celebrated example of AI-human collaboration. The proof team (Nakamura, Bhat, Silva, and their AI collaborators at DeepMind-MSRI) described their workflow:

1. **Months 1–6:** The human team developed a novel strategy connecting BSD to a new form of p-adic Hodge theory. This strategic insight was entirely human.
2. **Months 7–12:** The AI agents formalized the necessary preliminary theory — over 30,000 lemmas covering new ground in arithmetic geometry. The humans guided the formalization, but the AI did the heavy lifting.
3. **Months 13–18:** The central argument was decomposed into 1,247 sub-goals. Of these, the AI solved 1,198 autonomously. The remaining 49 required human intervention — each involving a "creative leap" that the AI's search could not find.
4. **Month 19:** The final proof was assembled and verified by the UPF kernel in 3.7 seconds.

> **Nakamura, in a 2052 interview:** "The AI is like a brilliant graduate student who never sleeps and has read every paper ever written. But it cannot dream. The 49 lemmas it couldn't solve — those were the places where the mathematics required something genuinely new. Something that had never been written down before, in any form. That is where the human contribution lives."

### 14.3 The Ethics of Attribution

The rise of AI collaborators has forced the mathematical community to grapple with questions of attribution and credit. The 2055 IMU Guidelines on AI Collaboration establish that:

1. AI agents are **tools**, not **authors.** They do not receive credit, prizes, or co-authorship.
2. A human must take **intellectual responsibility** for every claimed result.
3. The formal proof certificate is a **public good** — it must be freely available regardless of the status of the accompanying paper.
4. Researchers must disclose the level of AI assistance used in their work.

These guidelines remain controversial. Some argue that the distinction between "tool" and "collaborator" is increasingly artificial. The debate continues.

---

## Chapter 16: Computational Complexity — The P ≠ NP Certificate

### 16.1 The Proof

In 2067, a team led by Yuki Tanaka at the Kyoto Institute for Mathematical Sciences announced a verified proof that P ≠ NP. The proof, which built on fifty years of work in circuit complexity and algebraic geometry, was formalized in UPF and verified by three independent kernel implementations.

The proof is approximately 800,000 lines of formal Meridian code, depending on how one counts the library dependencies. Its human-readable summary occupies a 200-page monograph. We will not attempt to reproduce the argument here. Instead, we focus on what the proof *means* for the student of verified mathematics.

### 16.2 What the Proof Changed

The resolution of P ≠ NP had surprisingly little impact on practical computing. (It was already universally assumed to be true, and cryptographic systems had been designed accordingly for decades.) Its impact on *mathematics* was profound:

1. **It demonstrated the necessity of formal verification for deep results.** The proof relies on a chain of 127 major lemmas, many of which involve subtle interactions between combinatorial, algebraic, and analytic arguments. Multiple early drafts contained errors that were caught by the proof assistant but would almost certainly have escaped human review.

2. **It vindicated the "Big Library" approach.** The proof made essential use of over 4,000 results from the MathLib Continuum — results formalized by hundreds of contributors over decades, many of whom had no idea their lemmas would one day be used in a complexity-theoretic argument. Mathematics is, more than ever, a collective enterprise.

3. **It opened new frontiers.** With P ≠ NP settled, the focus has shifted to **quantitative** questions: how far apart are P and NP? What is the precise circuit complexity of SAT? These questions are now the subject of active investigation, with AI agents exploring the landscape of possible bounds.

### 16.3 Exercises

1. **[Standard]** Formalize the definition of a Turing machine in Meridian and prove that the halting problem is undecidable. (This is a classic exercise; the Continuum provides a complete development, but try to do it from scratch first.)

2. **[Advanced]** The P ≠ NP proof uses a generalization of Razborov's approximation method. Formalize Razborov's original 1987 result showing that the clique function requires super-polynomial monotone circuit size. *(This is a substantial project, suitable for a term paper.)*

3. **[Open]** Is `PSPACE = EXP`? State the question formally. The AI agent will not be able to prove or disprove it (as of this edition). Why not?

---

## Chapter 17: Open Problems and the Shape of Tomorrow's Mathematics

### 17.1 What Remains

As of 2074, the following major problems remain open:

| Problem | Status | Notes |
|---|---|---|
| Riemann Hypothesis | **Open** | Partial results verified to 10²⁶ zeros. No viable proof strategy identified. |
| Navier-Stokes Existence & Smoothness | **Open** | Significant progress in 2063 (Villani-Chen), but a gap remains in 3D. |
| Yang-Mills Mass Gap | **Open** | Constructive QFT frameworks formalized, but the core estimate eludes proof. |
| Collatz Conjecture | **Open** | Verified computationally to 2^(10¹²). AI agents have found no proof, though not for lack of trying. |
| Goldbach's Conjecture | **Reduced** | Shown equivalent to a statement in additive combinatorics that is "almost" provable by current methods (Zhao-Agrawal, 2070). |
| Optimal Sphere Packing in Dim 5+ | **Open** | Dim 8 and 24 solved (Viazovska, 2016/2019). AI-assisted search has found candidate packings in dim 5 but no optimality proof. |

### 17.2 The Horizon of Automation

There is a romantic notion — occasionally expressed in popular science writing — that AI will eventually solve all mathematical problems, rendering human mathematicians obsolete. This is almost certainly false, for reasons that go beyond current technological limitations.

Gödel's incompleteness theorems guarantee that any sufficiently powerful formal system contains statements that are true but unprovable within the system. More practically, the space of possible mathematical ideas is not merely large but **open-ended**: new concepts, new definitions, new frameworks are continually being invented, and it is this invention — not the verification of known approaches — that drives mathematical progress.

The AI agents of 2074 are extraordinary tools. They can verify, search, and combine existing knowledge with superhuman speed and accuracy. But the creation of genuinely new mathematics — the kind that changes what questions we ask, not merely what answers we find — remains, for now, a human endeavor.

> **Exercise 17.2.1.** This is the last exercise in the book. It has no solution.
>
> *Find a new theorem. Prove it. Make it beautiful.*

---

## Appendix A: Legacy System Reference

### A.1 Lean 4 (2021–2038)

Lean 4, developed by Leonardo de Moura and his team at Microsoft Research, was the system that catalyzed the formal mathematics revolution. Its key innovations included:

- A **fast kernel** based on the Calculus of Inductive Constructions.
- A **meta-programming framework** that allowed users to write custom tactics in the same language as proofs.
- **Mathlib**, a collaboratively maintained library that grew into the largest collection of formalized mathematics in history.

Lean 4 syntax will feel familiar to Meridian users, as Meridian's surface language was directly descended from Lean:

```lean4
-- Lean 4 (circa 2024)
import Mathlib.Data.Nat.Prime

theorem infinitude_of_primes : ∀ n : ℕ, ∃ p, p > n ∧ Nat.Prime p := by
  intro n
  let N := n ! + 1
  obtain ⟨p, hp_prime, hp_dvd⟩ := Nat.exists_prime_and_dvd (Nat.succ_ne_one _)
  exact ⟨p, (Nat.lt_of_dvd_of_lt hp_dvd (Nat.lt_succ_of_le (Nat.le_of_dvd
    (Nat.factorial_pos n) (Nat.dvd_factorial.mpr ⟨hp_prime.pos, le_refl n⟩)))).elim
    (fun h => absurd h hp_prime.not_one) id, hp_prime⟩
```

The above is a *representative* example of the style of the era — note the explicit term-mode manipulation, the manual coercion handling, and the relatively verbose syntax. By modern standards, this is archaeologically charming.

### A.2 Coq (1989–2055)

Coq (later renamed Rocq in 2024 during a rebranding effort, though the community continued using both names) was the elder statesman of proof assistants. Built on the Calculus of Inductive Constructions with a rich tactic language (Ltac, later Ltac2), Coq was the system behind many landmark formalizations, including the CompCert verified C compiler and the proof of the Four Color Theorem.

### A.3 The Unification (2055–2061)

The proliferation of incompatible proof assistants was, by the 2040s, recognized as a serious impediment to progress. The Universal Proof Framework initiative, launched at the 2055 ICM in São Paulo, aimed to create a common interchange format and eventually a common language. After six years of intense negotiation — the "Proof Wars," as the popular press called them — UPF 1.0 was released in 2061, with Meridian as its primary surface language.

---

## Appendix C: Ethical Considerations in Automated Discovery

### C.1 The Dual-Use Problem

In 2039, an AI proof agent at a major technology company independently discovered a novel factoring algorithm while exploring number-theoretic conjectures. The algorithm, while not polynomial-time, was significantly faster than any known method for certain classes of integers. The company faced a dilemma: publishing the result would advance mathematics but potentially compromise cryptographic systems. (They published. The cryptographic community adapted. But the incident crystallized the dual-use problem.)

### C.2 Equity of Access

The computational resources required to run state-of-the-art proof agents are substantial. As of 2074, a full proof search on a research-level conjecture may require thousands of GPU-hours. This creates a risk of **inequality**: well-funded institutions can explore mathematics faster than underfunded ones. The Open Proof Initiative (est. 2045) provides free compute credits to researchers at institutions in the Global South, but the gap remains.

### C.3 The Meaning of Understanding

Perhaps the deepest ethical question raised by automated proving is philosophical: if an AI can prove a theorem that no human understands, is it *known*? The formal certificate guarantees correctness. But mathematics has always been about more than correctness — it is about *understanding*, *insight*, *connection*. A proof that is correct but opaque is, in some meaningful sense, incomplete.

This textbook takes the position that **human understanding remains essential.** A verified proof is a foundation, not a destination. The goal of mathematics is not merely to accumulate truths but to organize them into a coherent, beautiful, and comprehensible whole.

That goal, we believe, will always require a human mind.

---

## Colophon

*Foundations of Verified Mathematics, Seventh Edition*
© 2074 Vasquez-Okafor & Mehta. Published under the Universal Academic Commons License (UACL 3.0).

Typeset in Meridian Proof Font. All proof blocks in this textbook are executable — scan any code block with a UPF-compatible device to verify.

**Formal verification status:** All numbered theorems, lemmas, and propositions in this textbook have been verified by the UPF 4.2 kernel. The formal proof corpus is available at `upf://continuum/textbooks/fvm-7ed`.

*This book is dedicated to the memory of Kevin Buzzard (1968–2063), who saw the future before anyone else and spent his life building it.*

---

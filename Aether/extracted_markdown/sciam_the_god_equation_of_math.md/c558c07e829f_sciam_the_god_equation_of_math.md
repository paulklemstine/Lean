# The God Equation of Mathematics

## One formula to compute them all: How a physicist in Kraków found the atom of mathematical computation

*A Scientific American-style feature — April 2026*

---

### The Periodic Table Has One Element

What if chemistry had just one element? One type of atom that, combined with itself in clever ways, could build every molecule, every compound, every material? It sounds absurd for chemistry — but in 2025, a physicist discovered that mathematics works exactly this way.

Andrzej Odrzywolek, a physicist at Jagiellonian University in Poland, found that a single mathematical operation called **EML** — short for *Exp-Minus-Log* — can build every elementary mathematical function ever invented. Sine, cosine, square roots, logarithms, exponentials, multiplication, division, even the number π — all of them emerge from one formula:

**eml(x, y) = e^x − ln(y)**

paired with a single constant: the number **1**.

That's all you need. Two ingredients. Everything else in mathematics' standard toolkit is a consequence.

---

### What Does This Actually Mean?

Pick up a scientific calculator. It has 30 or 40 buttons: sin, cos, tan, log, exp, √, x², +, −, ×, ÷, and many more. Each represents a distinct mathematical operation refined over centuries by the greatest minds in history — Euler, Gauss, Fourier, Riemann.

Now imagine replacing *every single button* except "1" with a single button labeled **EML**. Press EML with inputs 1 and 1, and you get Euler's number *e* ≈ 2.718. Press EML three times in a nested pattern, and you get 0. Keep building, and eventually you can compute anything a full calculator can.

"It's like discovering that LEGO blocks are unnecessary — you can build anything from a single shape of brick," says one researcher working on formalizing the discovery.

---

### The Digital Precedent

This isn't entirely unprecedented. In 1913, logician Henry Sheffer proved that a single logic gate called NAND (short for "not and") could build any Boolean circuit. Every computer chip ever manufactured — from the processor in your phone to the servers running the cloud — could, in principle, be built entirely from NAND gates.

But NAND lives in the world of 0s and 1s. Mathematics also has a continuous world — the real numbers — where functions like sine and exponential live. For over a century, no one found the NAND equivalent for this continuous realm.

EML is that equivalent. It is the first known *continuous Sheffer operator*.

---

### How the Magic Works

The key insight is wonderfully simple. Start with two observations:

**First:** When you set y = 1 in eml(x, y), the logarithm term vanishes (since ln(1) = 0), giving you eml(x, 1) = e^x. That's the exponential function — already recovered from one application.

**Second:** Through a clever three-level nesting, you can extract the logarithm:
   ln(z) = eml(1, eml(eml(1, z), 1))

Once you have both exp and ln, a remarkable chain reaction begins. Addition becomes log(exp(x) · exp(y)). Multiplication becomes exp(ln(x) + ln(y)). The imaginary unit *i* emerges as exp(ln(−1)/2), which requires first generating −1 through a longer chain. Trigonometric functions follow from Euler's formula e^(iθ) = cos θ + i sin θ.

Even the number π appears: π = −i · ln(−1). Every constant, every function on your calculator, is built from this single recursive process.

---

### The Zero Moment

Perhaps the most elegant result is the generation of zero. Researchers have now formally proved — with machine-verified mathematical proof — that:

**eml(1, eml(eml(1,1), 1)) = 0**

Here's why: eml(1,1) = e. Then eml(e, 1) = e^e ≈ 15.15. Finally, eml(1, e^e) = e − ln(e^e) = e − e = 0.

Zero appears at "level 3" of the EML tower — requiring exactly 7 leaves and 6 EML nodes in its expression tree. This is the simplest possible representation; no tree with fewer nodes produces zero. The moment zero becomes available, all integers follow through repeated application, and from integers, all rational numbers, and eventually all algebraic numbers.

---

### The Proof Is in the Computer

What makes this discovery especially compelling is that the key results have been formally verified by computer. A team of researchers has encoded 68+ theorems about EML in the **Lean 4** proof assistant — the same system used by mathematicians to verify cutting-edge results in algebra and analysis.

Every identity, every existence theorem, every inequality has been checked line by line by a computer. Zero human errors. Zero gaps in logic. The proofs include:

- EML recovers exp and ln ✓
- EML generates the constant 0 ✓  
- The EML operator is non-commutative and non-associative ✓
- EML trees satisfy leaves = nodes + 1 ✓
- The logarithmic fixed point exists and is unique ✓
- EML is jointly continuous and C^∞ in its first argument ✓

"Machine-verified proofs are the gold standard," says one team member. "There's no room for the subtle errors that sometimes creep into human proofs."

---

### Why Should Anyone Care?

The discovery is beautiful mathematics, but its implications reach far beyond pure theory.

**Symbolic Regression.** Machine learning researchers use EML trees as a "master formula" framework for discovering mathematical laws from data. Instead of searching over combinations of dozens of functions, the search space collapses to trees of a single operation. Early experiments show that EML-based symbolic regression can rediscover known physical laws from noisy data.

**Hardware Design.** Just as NAND gates simplified chip design by requiring only one gate type, EML could inspire new mathematical coprocessor architectures. A single hardware unit implementing eml(x,y) could, in principle, compute any elementary function through iterated application.

**Compression and Complexity.** EML provides a canonical measure of mathematical complexity: the *EML complexity* of a function is the smallest tree that computes it. This creates a rigorous framework for asking "how complex is multiplication?" (answer: between 17 and 41 EML leaves) or "how complex is π?" (currently bounded by 53 leaves, conjectured to be ≤ 40).

**Education.** The conceptual simplification is profound. Instead of teaching dozens of seemingly unrelated functions, mathematics could be presented as a unified theory built from a single primitive — much as chemistry teaches atoms before molecules.

---

### The Mysteries That Remain

The discovery opens as many questions as it answers.

**Is EML the only one?** No — variants like exp(x)/ln(y) also work. But nobody knows the complete family of continuous Sheffer operators. Classifying them all is a major open problem.

**Can you do it without the constant 1?** The NAND gate needs no constants — it generates both 0 and 1 from any input. Does a continuous analog exist? A binary function that generates all elementary functions from *any* starting point? This "Constant-Free Sheffer Conjecture" is considered one of the deepest open questions in the field.

**How deep must the trees go?** The EML complexity of basic functions grows rapidly: exp is 3, ln is 7, addition is around 15, multiplication is at least 17. What about more complex functions? Is there an exponential blowup, or do clever constructions keep trees manageable?

**What about non-elementary functions?** The gamma function, the Riemann zeta function, elliptic functions — none of these are elementary. Can EML be extended to capture them? Or is elementarity a fundamental boundary?

---

### The View from Kraków

Odrzywolek's discovery emerged from the intersection of physics and computation. As a physicist studying stellar evolution, he routinely worked with complicated mathematical expressions and wondered whether they could be simplified. His systematic computer-aided search — testing whether various combinations of exp and ln could recover all standard functions — led to the EML discovery.

"It was hiding in plain sight," he has said. "The exponential and the logarithm are inverses. Put them together in just the right way, and they generate everything."

The mathematical community is still absorbing the implications. New theorems are being proved monthly, and the Lean 4 formalization grows steadily. The 10 conjectures posed by the research team span decades of potential investigation.

But perhaps the deepest lesson is philosophical. Mathematics, for all its apparent diversity — its trigonometries and topologies, its algebras and analyses — has a hidden unity. At the root of it all, there may be just one operation and one number.

One button and 1.

---

*The EML operator formalization is available as open-source Lean 4 code. The research team welcomes collaborators and has identified 30+ open research directions spanning pure mathematics, computer science, machine learning, and theoretical physics.*

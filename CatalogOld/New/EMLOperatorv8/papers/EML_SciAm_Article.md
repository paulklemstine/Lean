# The One Equation That Rules Them All

## How a deceptively simple formula — exp(x) minus log(y) — is reshaping mathematical foundations

---

*Imagine a single tool that could build every structure in a workshop — every joint, every curve, every fastener. In the digital world of Boolean logic, such a tool exists: the NAND gate, from which all computation flows. Now mathematicians have found something analogous for the continuous world of calculus and real numbers.*

---

### A Formula You Can Write on a Napkin

Take any two numbers, $x$ and $y$. Raise Euler's number $e \approx 2.718$ to the power $x$, then subtract the natural logarithm of $y$:

$$\text{eml}(x, y) = e^x - \ln y$$

That's it. The EML operator — short for "Exponential Minus Logarithm" — looks almost trivially simple. But appearances deceive. This single formula, when composed with itself, generates an astonishing amount of mathematics.

### Building Blocks from One Operation

Start with just the number 1 and the EML operator. What can you build?

**Step 1:** Plug in $x = 1$ and $y = 1$. Since $\ln(1) = 0$, you get $e^1 - 0 = e$. *You've just derived Euler's number.*

**Step 2:** Now use that $e$ as an input: $\text{eml}(e, 1) = e^e \approx 15.15$. *You've built the double exponential.*

**Step 3:** One more step gives $e^{e^e} \approx 3{,}814{,}279$. The growth is explosive — and it keeps going.

**Step 4:** By a slightly different path — $\text{eml}(1, e^e)$ — you get $e - e = 0$. *You've produced zero from nothing but $1$ and EML.*

The entire exponential function, all powers of $e$, zero, and (with more work) every elementary function in mathematics — sines, cosines, logarithms, polynomials — can be built from this single binary operation and one constant. Mathematicians call such an operation a "Sheffer operator" for continuous mathematics, by analogy with the NAND gate of logic.

### The Tower That Eats the Universe

One of the most spectacular consequences of EML involves the *e-tower*: the sequence $1, e, e^e, e^{e^e}, \ldots$ Each term is obtained by applying $\text{eml}(\cdot, 1)$ to the previous one.

The growth is beyond exponential — it's *superexponential*. The research team proved, with mathematical certainty, that the $(n+2)$th tower is at least $e^{2^n}$. By the time you reach $e\!\uparrow\uparrow\!5$, the number has more digits than there are atoms in the observable universe. The proof is not a hand-waving argument: it was verified line-by-line by the Lean proof assistant, a computer program that checks mathematical logic with absolute rigor.

### A Magma Like No Other

In abstract algebra, mathematicians study binary operations and the laws they obey. Addition is commutative ($a + b = b + a$) and associative ($a + (b + c) = (a + b) + c$). Multiplication shares these properties. Even exotic number systems like the quaternions and octonions satisfy *some* algebraic laws.

The EML operator satisfies *none of them*.

It's not commutative: $\text{eml}(1, 2) \ne \text{eml}(2, 1)$. It's not associative. It has no identity element — there's no number $e_0$ such that $\text{eml}(e_0, x) = x$ for all $x$. It fails mediality, flexibility, alternativity, idempotency, and distributivity. The research team systematically tested and formally disproved every standard algebraic identity in the textbook.

"It's like discovering an animal that breaks every rule of taxonomy," says the formalization effort's documentation. The EML magma (a set with a binary operation, no other assumptions) occupies a genuinely novel position in universal algebra.

### A Bridge to Inequality

Perhaps the most beautiful result connects EML to a famous inequality. The *AM-GM inequality* — that the arithmetic mean of positive numbers is at least their geometric mean — is one of the oldest and most widely used results in mathematics.

The team proved that for any positive numbers $a$ and $b$:

$$a + b - \ln a - \ln b \ge 2$$

This is the "AM-GM bridge": a natural rephrasing of the classical inequality through the EML lens. The minimum value of 2 is achieved exactly when $a = b = 1$.

### A Fixed Point in the Chaos

While the diagonal map $d(z) = e^z - \ln z$ has no fixed points (the team proved $d(z) > z$ for every real number $z$, and orbits diverge to infinity), a related map tells a different story.

The map $g(z) = e - \ln z$ has a single attracting fixed point at $z^* \approx 2.017$, which equals $W(e^e)$, where $W$ is the Lambert $W$ function. Starting from almost any positive number and iterating $g$, you spiral into this fixed point. The derivative at $z^*$ is $|g'(z^*)| = 1/z^* \approx 0.496$, confirming the attraction mathematically.

### Machine-Verified Certainty

What makes this project unusual is its standard of proof. Every single theorem — over 280 of them across eight versions — has been formally verified in Lean 4, a proof assistant that leaves no room for error. There are zero unproven statements (no "sorry"s in the code), and the proofs use only the standard axioms of mathematics.

This isn't just mathematical rigor; it's *mechanical* rigor. A human might overlook an edge case, but the computer checks every logical step. When the team proved that the EML operator is continuous on $\mathbb{R} \times (0,\infty)$, they also discovered — through formal verification — that it is *not* continuous globally (because $\ln y$ diverges as $y$ approaches zero from above). Even small surprises like this illustrate the value of formal methods.

### What Comes Next?

The implications stretch far beyond pure mathematics:

**Artificial Intelligence.** EML trees — nested compositions of the EML operator — offer a compact way to represent mathematical formulas. A 5-node EML tree has only about 20 parameters to tune, compared to millions in a typical neural network. This could revolutionize *symbolic regression*, the problem of discovering scientific laws from data.

**Hardware.** A single chip computing $e^x - \ln y$ could serve as a universal mathematical coprocessor. The monotonicity properties (output always increases with $x$, decreases with $y$) guarantee predictable behavior, simplifying circuit design.

**Number Theory.** Are $e$, $e^e$, and $e^{e^e}$ algebraically independent? Even proving $e^e$ is transcendental remains an unsolved problem. The superexponential growth bounds formalized in this project may provide new tools for attacking these questions.

**The Big Open Problem.** What is the EML complexity of the logarithm? We know $\text{eml}(x, 1) = e^x$ (one step), but inverting the exponential takes at least 3 steps and at most 5. Closing this gap is the project's top priority.

### The Lesson

The EML operator teaches a broader lesson about mathematics: apparent simplicity can hide extraordinary depth. A two-symbol formula — $e^x - \ln y$ — generates an entire universe of mathematical structure. Every elementary function lurks within it. Every classical algebraic law fails for it. Its dynamics produce numbers that dwarf the physical universe.

And all of this has been proved with mechanical certainty, line by verified line.

---

*The EML project is formalized in Lean 4.28.0 with the Mathlib library. All code and proofs are publicly available. The formalization currently contains 280+ theorems with zero unproven assertions.*

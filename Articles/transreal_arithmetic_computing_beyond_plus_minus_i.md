# Dividing by Zero on Purpose: A Guided Tour of Transreal Arithmetic

## The forbidden operation

Every schoolchild learns a rule so absolute it feels like a law of nature: *you cannot divide by zero*. Calculators flash an error. Spreadsheets turn red. Programs crash. The prohibition is not arbitrary — it protects the logical consistency of ordinary arithmetic. If we naively declared $1/0$ to be some number $n$, then $1 = 0 \cdot n = 0$, and the entire edifice of algebra collapses into a single point where everything equals everything else.

But there is another way to think about the problem. Instead of forbidding division by zero, what if we made it *total* — defined for every input, no exceptions — by widening the number system just enough to hold the answers? This is the ambition of **transreal arithmetic**, a system that extends the familiar real number line with three new values and then insists that every sum, product, and quotient you could ever write down returns a definite result. No errors. No crashes. No undefined behavior.

The price of that totality turns out to be surprisingly precise, and measuring it exactly is the subject of this article.

## Three new numbers

The transreal numbers, written $\mathbb{T}$, consist of the entire real line together with exactly three new symbols:

$$\mathbb{T} = \mathbb{R} \cup \{+\infty,\ -\infty,\ \Phi\}.$$

The first two, $+\infty$ and $-\infty$, are the signed infinities — the destinations you approach as you divide $1$ by an ever-smaller positive or negative number. The third, $\Phi$ (pronounced "nullity"), is the genuinely new idea. It is the value assigned to the most hopeless expression in arithmetic, the indeterminate form

$$\Phi = \frac{0}{0}.$$

Nullity is not a number in any usual sense. It is best understood as a permanent, self-propagating *error flag*. Once $\Phi$ appears anywhere in a calculation, it never goes away: it is absorbed by nothing and it poisons everything it touches. Add anything to $\Phi$ and you get $\Phi$. Multiply anything by $\Phi$ and you get $\Phi$. In symbols, for **every** transreal $x$,

$$\Phi + x = \Phi, \qquad \Phi \cdot x = \Phi.$$

This "stickiness" is the whole point. In ordinary computing, an undefined operation halts the machine. In the transreal world, the machine keeps running and simply carries the $\Phi$ forward, so that at the end of a long computation you can tell at a glance whether anything ever went irreparably wrong.

## The rules of engagement

To make division total, we first make the reciprocal total. The transreal reciprocal $1/x$ is defined for all $x$:

$$\frac{1}{0} = +\infty, \qquad \frac{1}{+\infty} = 0, \qquad \frac{1}{-\infty} = 0, \qquad \frac{1}{\Phi} = \Phi.$$

Division is then defined the obvious way, $x / y = x \cdot (1/y)$, and it is now genuinely total: you may divide any transreal by any transreal. The two most delicate cases behave as advertised. Dividing one by zero gives positive infinity, $1/0 = +\infty$, while dividing zero by zero gives nullity, $0/0 = \Phi$ — Anderson's defining identity, and the reason $\Phi$ has to exist at all.

Addition and multiplication extend the real operations by deciding what happens at the edges. Most cases follow intuition: $+\infty$ plus a finite number is still $+\infty$; a positive number times $+\infty$ is $+\infty$; a negative number times $+\infty$ is $-\infty$. But two combinations are famously indeterminate, and in the transreal system both are resolved by handing the result to nullity:

$$(+\infty) + (-\infty) = \Phi, \qquad 0 \cdot (\pm\infty) = \Phi.$$

The first says that adding opposite infinities is meaningless. The second says that the eternal tug-of-war between "zero times anything is zero" and "infinity times anything is infinite" has no winner — so nullity is declared instead. These two decisions, innocuous as they look, are the seeds of everything that follows.

## What survives

The remarkable news is how *much* of ordinary arithmetic keeps working. Both of the transreal operations remain beautifully behaved on their own terms.

Addition is **commutative** and **associative**, with $0$ still acting as the identity element: $x + 0 = x$ for every transreal $x$. Multiplication is likewise **commutative** and **associative**, with $1$ still the identity: $x \cdot 1 = x$ always. In the language of algebra, $(\mathbb{T}, +, 0)$ and $(\mathbb{T}, \cdot, 1)$ are each a **commutative monoid** — a set with an associative, commutative operation and an identity element. Nothing about the three exotic values breaks these laws.

Why are they so robust? Because the only truly dangerous combinations — the sum $+\infty + (-\infty)$ and the products $0 \cdot (\pm\infty)$ — were all routed straight into $\Phi$, and $\Phi$ is absorbing. Once a dangerous case produces nullity, every later operation faithfully preserves it, so there is never a moment where the "answer" depends on the order in which you grouped the terms. The stickiness of $\Phi$ is exactly what makes associativity survive.

And of course the ordinary reals sit inside $\mathbb{T}$ untouched: for finite $a$ and $b$, transreal addition and multiplication are just the usual $a+b$ and $a \cdot b$. Every classical identity you know still holds, as long as you stay away from the three new values. The extension is *conservative* over $\mathbb{R}$.

## What collapses

Here is where the story turns, and where the precise price of totality is finally revealed. Having two commutative monoids is a long way from having a rich algebra. The transreal system is **not a ring** — it lacks the single most important law linking addition and multiplication.

The first casualty is *subtraction*. In a ring, every element has an additive inverse; you can always solve $x + y = 0$. But $+\infty$ has no partner: adding anything at all to $+\infty$ can never yield $0$, because $+\infty$ plus a finite number is $+\infty$, and $+\infty + (-\infty)$ is $\Phi$. There is simply no way back to zero. Infinity is a trap you cannot subtract your way out of.

The second casualty is the **annihilator law**, the comfortable fact that $0 \cdot x = 0$. In the transreals this fails spectacularly at infinity: $0 \cdot (+\infty) = \Phi$, not $0$. Zero has lost its power to zero things out.

And the third — the deepest — is **distributivity**, the law $(x+y)\cdot z = x\cdot z + y \cdot z$ that lets us expand brackets. Watch it break. Take $x = 2$, $y = -1$, and $z = +\infty$. On the left,

$$(2 + (-1)) \cdot \infty = 1 \cdot \infty = +\infty.$$

On the right,

$$2 \cdot \infty + (-1) \cdot \infty = (+\infty) + (-\infty) = \Phi.$$

One side is a perfectly good infinity; the other is nullity. The two are not equal, and no amount of clever redefinition will make them equal, because the failure is structural: expanding the bracket forces the arithmetic to add $+\infty$ to $-\infty$, and that sum is doomed to be $\Phi$.

Even a weaker kind of bookkeeping fails. **Cancellation** — the rule that lets you deduce $a = b$ from $a + c = b + c$ — is gone. We have $+\infty + 1 = +\infty + 2$, since both equal $+\infty$, yet $1 \neq 2$. Infinity swallows the distinction.

## Not a ring — but not a wheel either

Mathematicians have a name for structures designed precisely to make division total: they are called **wheels**, the name evoking the circular symbol $\odot$ of a number line whose two ends have been joined through a single point at infinity. Wheels relax the ring axioms in carefully chosen ways — they replace distributivity with a modified law that carries a correction term, and they demand that the reciprocal operation be an *involution*, meaning that applying it twice returns you to where you started: $1/(1/x) = x$.

It would be a tidy ending if the transreals turned out to be a wheel. They are not — and understanding why sharpens our picture of exactly where they sit.

Consider the wheel's substitute for distributivity, the modified law

$$(x + y)\cdot z + 0 \cdot z = x \cdot z + y \cdot z.$$

The extra term $0 \cdot z$ is meant to be a gentle correction, harmless in ordinary cases. But in the transreals it is anything but harmless. Take $x = 2$, $y = 3$, $z = +\infty$. The correction term is $0 \cdot \infty = \Phi$, which immediately poisons the entire left-hand side down to $\Phi$. The right-hand side, meanwhile, is $2 \cdot \infty + 3 \cdot \infty = +\infty$. Once again $\Phi \neq +\infty$, and the wheel law fails.

The reciprocal fails the wheel test too. A wheel insists $1/(1/x) = x$. But start with $-\infty$: its reciprocal is $1/(-\infty) = 0$, and the reciprocal of $0$ is $+\infty$. So applying the reciprocal twice sends $-\infty$ to $+\infty$ — the wrong sign. The reciprocal is not an involution.

Both failures trace back to a single feature: the transreals distinguish $+\infty$ from $-\infty$. A wheel built on the classical *one-point* projective line has only a single unsigned infinity, and there the reciprocal genuinely is an involution and the modified law genuinely holds. The transreals, by splitting infinity into two signed halves, break exactly the axioms the one-point wheel preserves.

## The verdict

So we can now state, with precision, what a transreal number system *is*. It is neither a ring nor a wheel but something new and strictly weaker than both:

> **A pair of commutative monoids sharing a single global absorbing element $\Phi$, equipped with a division operation that is total but not involutive.**

That is the exact price of totality. To guarantee that every division returns an answer, we must give up subtraction as an inverse, give up the annihilating power of zero, give up expanding brackets, and give up cancellation — while keeping, intact and pristine, the two commutative monoids and the conservative copy of the ordinary reals living inside.

## Why it matters

This might sound like a purely recreational exercise — arithmetic for the sake of breaking taboos. It is not. The transreal design principle is exactly the one behind the **IEEE 754 floating-point standard** that governs essentially every computer on Earth. That standard, too, extends the reals with signed infinities and with a special value, `NaN` ("not a number"), that behaves precisely like nullity: it is produced by $0/0$, it is sticky, and it propagates through a computation as a self-flagging error. When your program computes with `NaN` and does not crash, you are watching a cousin of transreal arithmetic at work.

The mathematics above explains, rigorously, *why* such systems have the shape they do. You cannot have totality and the ring laws at the same time — the incompatibility is not an engineering compromise but a theorem. The absorbing error element is not a hack; it is the unique price of never having to say "undefined." And the split between $+\infty$ and $-\infty$, so convenient for representing overflow in one direction or the other, is precisely what forbids the clean involutive reciprocal of the abstract wheel.

Transreal arithmetic, then, is a small, self-contained universe where dividing by zero is not a sin but a well-defined act — and where the exact cost of that freedom can be written down, weighed, and understood. Sometimes the most illuminating thing mathematics can do is tell you, with total precision, what you must give up to get what you want.

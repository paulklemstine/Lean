# The Tokenizer Tax Explodes

### Why writing to a machine in German costs more than writing to it in English — and why that surcharge quadruples when the conversation gets long

---

## A tax you never agreed to pay

Every large language model reads text through a **tokenizer**: a fixed dictionary that
chops a stream of characters into a sequence of atoms. English, which dominates the
training corpora from which these dictionaries are built, gets a generous deal. Common
English words are single tokens. German, with its long compounds and its umlauts, gets a
worse deal: *Rechtsschutzversicherungsgesellschaft* is not one atom but a handful, and
even ordinary German prose is chopped more finely than the equivalent English.

The consequence is quiet and unglamorous. To say the same thing, German prose spends more
tokens. Call the ratio $\lambda$: a language with fragmentation ratio $\lambda$ needs
$\lambda$ tokens where the reference language needs one. For German against English,
$\lambda$ is somewhere around $1.2$ to $1.5$, depending on the tokenizer.

This is the **tokenizer tax**. In a world of unlimited memory it would be a mild
annoyance — a few percent more compute. But nobody deploys with unlimited memory. Real
systems keep a *bounded cache* of attention keys: only the top $k$ positions in the
context are retained, and everything else is dropped. So the tokenizer tax turns into a
question about how many cache slots you have to buy. And that question, it turns out, has
a sharp and rather alarming answer.

---

## The measurement that started this

Run German prose through a fixed retrieval harness at a context length of $4096$ tokens.
Retain the top $k$ attention keys, and measure what fraction of the true attention mass
survives. The deployment bar is $0.98$ — retain 98% of the mass and downstream quality is
preserved.

| keys $k$ | 24 | 32 | 40 | 48 | 56 |
|---|---|---|---|---|---|
| retained | $0.953$ | $0.966$ | $0.973$ | $0.975$ | $0.976$ |

Every single point fails. Even $k=56$ retains only $0.976$. At shorter contexts the same
harness on the same language had shown a modest, tolerable penalty: German needed about
**four more keys** than English to clear the same bar. At $4096$ that $+4$ has become at
least $+16$.

Three hypotheses were on the table before the measurement. **P1**: the tax compounds with
context length. **P2**: the tax dissolves — at long context everything is expensive and
the language difference washes out. **P3**: the tax stays put at a fixed additive offset,
so budget tables can just add a constant column for German.

P1 is confirmed. P2 and P3 are dead. And the factor by which the tax grew — exactly
$4\times$ — is not a coincidence: it is precisely the factor by which the *baseline*
English requirement grew over the same stretch of context. That coincidence is the whole
story, and the rest of this article is about why it is not a coincidence at all but a
theorem.

---

## Where the numbers come from: a recall curve

The measured table has a shape, and the shape is a power law. Write the **recall deficit**
— the fraction of attention mass you *lose* by keeping only $k$ keys — as

$$\mathrm{deficit}(k) = A \, k^{-a}, \qquad \mathrm{retained}(k) = 1 - A\,k^{-a}.$$

Two numbers: an amplitude $A$ (how hard the workload is) and an exponent $a$ (how fast
extra keys help). Fitting the German table gives $a \approx 0.810$ and $A \approx 0.582$,
with residuals below $0.004$ at every one of the five points.

Now ask the deployment question: how many keys do you need to clear a bar $\tau$? Solve
$1 - A k^{-a} \ge \tau$ and you get an exact answer, not a bound:

> **The Gate Theorem.** For $A>0$, $a>0$, $\tau<1$ and $k>0$,
> $$\mathrm{retained}(k) \ge \tau \iff k \ge \Big(\tfrac{A}{1-\tau}\Big)^{1/a}.$$

The right-hand quantity is the **budget** $\mathcal{B}(A,a,\tau)$. It is a genuine
threshold: below it you fail, at or above it you pass. And because the retained fraction
is strictly increasing in $k$, one failing measurement at $k=56$ certifies failure at
*every* smaller budget — the German table doesn't have five independent failures, it has
one failure and a monotonicity argument. Plugging in the fitted constants gives a budget
of roughly $64$ keys for $\tau = 0.98$: the experiment simply never spent enough.

---

## The two knobs, and the one place they meet

The amplitude $A$ is where the physics lives. Two things make a workload harder:

- **Context length $C$.** More context means more attention mass spread over more
  positions, so the top-$k$ slice recovers relatively less. Empirically the amplitude
  grows like a power: $A \propto C^{\,b}$.
- **Language.** A language with fragmentation ratio $\lambda$ packs the same *content*
  into $\lambda$ times as many tokens. As far as the attention mechanism is concerned,
  German at context $C$ **is** the reference language at context $\lambda C$.

Put them together: the amplitude is $A(\lambda, C) = A_0 (\lambda C)^b$. And now watch
what the budget does. The budget is a power $1/a$ of the amplitude, and powers turn
products into products:

> **Homogeneity.** $\mathcal{B}(cA, a, \tau) = c^{1/a}\,\mathcal{B}(A,a,\tau)$ for every
> $c \ge 0$.

So the language knob doesn't *add* to the budget. It *multiplies* it:

$$\mathcal{B}(\lambda, C) \;=\; \lambda^{\,b/a}\cdot \mathcal{B}(1,C).$$

The factor $\chi(\lambda) = \lambda^{b/a}$ is the **amplification factor** of the
language. It does not depend on the bar $\tau$ you chose, nor on the absolute difficulty
$A_0$ of the workload, nor on the context length. It is a pure property of the language
against the tokenizer — and it is *multiplicative*: chaining two fragmenting effects
multiplies their amplifications, $\chi(\lambda_1\lambda_2) = \chi(\lambda_1)\chi(\lambda_2)$,
with $\chi(1)=1$. In algebraic language, the tokenizer tax is a **character** of the group
of fragmentation ratios.

---

## The multiplicative law

The *tax* is the additive thing everyone actually budgets with: how many extra keys does
German need, over English, at this context?

$$T(\lambda, C) \;=\; \mathcal{B}(\lambda, C) - \mathcal{B}(1, C) \;=\; \big(\chi(\lambda) - 1\big)\,\mathcal{B}(1,C).$$

That single line is the punchline. The additive tax is a **fixed multiple of the baseline**.
It therefore scales exactly as the baseline scales:

> **The Multiplicative Law.** For any two context lengths $C_1, C_2$,
> $$T(\lambda, C_2)\cdot \mathcal{B}(1,C_1) \;=\; T(\lambda, C_1)\cdot \mathcal{B}(1,C_2).$$
> Equivalently: if the baseline requirement grows by a factor $\rho$ between $C_1$ and
> $C_2$, then the tax grows by the same $\rho$.

Set $\rho = 4$ and $T(\lambda,C_1) = 4$ and you get $T(\lambda,C_2) = 16$. That is the
headline transition, derived rather than fitted. The measured $4\times$ amplification of the
tax is not a new empirical parameter; it is the *already-measured* $4\times$ acceleration
of the baseline, wearing a different hat.

The same identity kills P2 and P3 at a stroke. The tax is $(\chi(\lambda)-1)$ times a
baseline that diverges with context, so for a genuinely fragmenting language
($\chi(\lambda)>1$) the tax is **unbounded**: for every ceiling $M$ you name, some context
length pushes the tax past it. It cannot dissolve. And it cannot stay put either — there
is no constant $t$ with $T(\lambda,C)=t$ for all $C$. Sharper still:

> **Rigidity of a constant tax.** $T(\lambda,C_1)=T(\lambda,C_2)$ holds if and only if
> either $\chi(\lambda)=1$ (the language is free) or $\mathcal{B}(1,C_1)=\mathcal{B}(1,C_2)$
> (the baseline didn't move). There is no third way.

---

## Why your budget spreadsheet is wrong

Engineering teams size KV caches from tables: a row per context length, a column per
language, add them up. That practice assumes the budget is **separable** —
$\mathcal{B}(\lambda,C) = f(C) + g(\lambda)$ for some pair of functions. It isn't, and the
failure is total rather than approximate:

> **No Additive Budget Table.** If $\mathcal{B}(\lambda, C) = f(C) + g(\lambda)$ for all
> positive $\lambda$ and $C$, then $\chi(\lambda) = 1$. In particular, for any genuinely
> fragmenting language $\lambda > 1$ no such $f,g$ exist at all.

The proof is a one-line consequence of the multiplicative structure: separability forces
$\mathcal{B}(\lambda,C)-\mathcal{B}(1,C)$ to be independent of $C$, but that difference is
$(\chi(\lambda)-1)\mathcal{B}(1,C)$, which moves with $C$ unless $\chi(\lambda)=1$. A
correct budget table must carry a **language $\times$ context interaction term**. Nothing
less will do.

What *is* additive is the logarithm. Taking logs of the budget gives

$$\log \mathcal{B}(\lambda, C) = \tfrac1a\log\tfrac{A_0}{1-\tau} \;+\; \tfrac{b}{a}\log\lambda \;+\; \tfrac{b}{a}\log C,$$

an affine function of $\log\lambda$ and $\log C$ **with the same slope $b/a$ in both**.
That shared slope is the exchange symmetry made visible: a language shift and a context
stretch are literally the same operation, since German at context $C$ costs exactly what
the reference language costs at context $\lambda C$. Budget in log-space, or don't budget
at all.

One might hope that the coarse granularity of real hardware saves you — caches come in
blocks, so maybe rounding absorbs the growth. It does not. If keys are allocated in blocks
of size $g$, quadrupling the real tax costs at least $4N-3$ blocks where the old tax cost
$N$; and no finite block surcharge is safe, since for every block count $N$ there is a
context length whose tax exceeds it. On a grid of $4$, a tax of $4$ is one block and a tax
of $16$ is four.

---

## The explosion, and where it comes from

There is one more twist, and it is the reason the verdict is *explodes* rather than merely
*grows*. The measured recall exponent is **sub-linear**: $a \approx 0.810 < 1$. And that
inequality is not an artifact of the fit — it is forced by the data. From the two anchor
points of the German table alone (a deficit of $0.047$ at $k=24$ and $0.024$ at $k=56$),
one derives $a<1$: keys buy less recall than proportionally, because
$56/24 \approx 2.33$ while $0.047/0.024 \approx 1.96 < 2.33$.

Sub-linearity is the engine. Because the budget is the $1/a$ power of the amplitude and
$1/a > 1$, the budget responds **super-linearly** to any hardening of the workload:

> **Super-linear response.** If $a < 1$ and $c>1$, then
> $\mathcal{B}(cA,a,\tau) > c\,\mathcal{B}(A,a,\tau)$.

Doubling the difficulty more than doubles the bill. Applied to the language knob this says
the amplification $\lambda^{b/a}$ strictly exceeds the naive token-count penalty
$\lambda^{b}$: you pay more than the extra tokens you spent. The tax compounds with itself.

---

## Is the law an artifact of the model?

A skeptic is entitled to object. All of the above lives inside one two-parameter family —
the power-law recall curve. Maybe the multiplicative law is a property of that algebraic
shape and nothing more.

It isn't, and here is the argument. Strip the model away and keep only one structural
feature. Call a positive function $\mathcal{B}(C)$ of the context length a **dilation
budget** if stretching the context by a factor $u$ rescales the budget by some factor
$\chi(u)$ depending on $u$ alone:

$$\mathcal{B}(uC) = \chi(u)\,\mathcal{B}(C) \quad\text{for all } u, C > 0 .$$

That is all. Nothing about power laws, nothing about $\tau$. And yet:

> **The response factor is forced to be a character.** In any dilation budget,
> $\chi(1)=1$ and $\chi(uv) = \chi(u)\chi(v)$.

Multiplicativity is *derived*, not assumed — it falls out of associativity of dilation,
because $\mathcal{B}(u(vC))$ and $\mathcal{B}((uv)C)$ are the same number. Since a language
shift is precisely a dilation, every language tax is $(\chi(\lambda)-1)\mathcal{B}(C)$, and
the multiplicative law, the unboundedness, the no-separable-table theorem, and the
constancy dichotomy all reappear verbatim — in *every* dilation budget.

To show the abstraction has more than one inhabitant, consider a completely different
micro-model. Suppose attention mass is distributed over a continuum of positions in
$(0,C]$ with a **Zipf profile** $x \mapsto x^{-s}$, for $s<1$ (the condition that makes the
mass integrable at the origin). Then the total mass is
$$\int_0^C x^{-s}\,dx = \frac{C^{\,1-s}}{1-s},$$
and the fraction recovered by the top $k$ positions is a clean ratio computed from those
integrals, not postulated:
$$\mathrm{retained}(k) = \Big(\frac{k}{C}\Big)^{1-s}.$$
Its gate is exact — the bar $\tau$ is met if and only if $k \ge \tau^{1/(1-s)}C$ — so the
Zipf budget is $\mathcal{B}(C) = \tau^{1/(1-s)}C$, a dilation budget with the identity
character $\chi(u)=u$.

Two models sharing no parameter and no functional form, both obeying the same law. And
their characters coincide exactly when $b=a$, which tells you precisely what the experiment
measures: the *law* is structural and untestable; the *exponent* is the empirical content.
The measured $4\times$ amplification at $4096$ is a measurement of $b/a$, and of nothing
else.

---

## What to do on Monday morning

The theory makes two predictions that cost nothing to test and could falsify it outright.

**The language ratio is a context invariant.** Each language's tax diverges, but the ratio
of two languages' taxes is the same at every context length: measure French and German at
two context lengths and check
$T_{\mathrm{fr}}(C_1)T_{\mathrm{de}}(C_2) = T_{\mathrm{fr}}(C_2)T_{\mathrm{de}}(C_1)$.
No free parameters, no fitting.

**Rankings never cross.** If one language's character is at least another's, its tax is at
least the other's at *every* context length. A less-fragmenting French should sit strictly
between the English baseline and the German curve at $4096$ — never above it at one context
and below at another.

And the deployment consequence is blunt. Multilingual agentic workloads face
disproportionately growing cache costs for non-English languages as context extends beyond
roughly two thousand tokens. The surcharge you measured at short context is not the
surcharge you will pay. Whatever number is in your table, multiply it by however much your
baseline grew — because that is not a heuristic, it is an identity.

The tokenizer tax does not wash out at scale. It is a character of the language, and
characters multiply.

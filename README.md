# Cateno
=======
Cateno is a system for computational category theory and applications.  It provides an interactive calculator for free morphism expressions and string diagram generation. It also handles concrete categories, and can be used as a typed numerical linear algebra system.  Algorithms are implemented at the level of catgorical abstraction: you just need to specify how the necessary interface is implemented, and you have access to fast algorithms for inference, tree decomposition, contraction, and so on.  This enables fast development of models of uncertainty.

Check out the static demos (Ipython/Jupyter notebooks): [qubits](https://github.com/jasonmorton/Cateno/blob/master/demo/ThreeQubitsFTS.ipynb), and screencasts:

Cateno is primarily written in Julia. 
Cateno can be used in an IPython/Jupyter notebook, interactively at the Julia prompt (with diagram-drawing in a separate window), or as a set of libraries.  In the future we plan to make available bindings or ports to other languages.

## Goals

A practical computer algebra system for computational (monoidal) category theory should be able to:

1. manipulate abstract categorical quantities such as morphism terms in a REPL.
2. compile/lower code expressed categorically to an efficient implementation in a particular category (e.g. numerical linear algebra, (probabilistic) databases, quantum simulation, belief networks).
3. scale to be useful for practical computational problems in modeling uncertainty in data analysis, statistics, physics, computer science.

There is more than one way to accomplish (1), and our design choices are driven by (2) and (3) as well.  In particular we use wrapper classes (wrap an untyped object in a typed wrapper) and representations (functorial bindings) whenever possible. 

For people interested primarily in modeling, rather than computational category theory in its own right, it  should be able to:  

4. Ingest qualitative domain knowlege expressed with flow charts/diagrams from non-programmers
5. Attach multiple competing quantitative explanations (e.g.\ probabilistic, differential equation, discrete dynamical) and test them
6.  Port algorithms, using best solution in each component (e.g. tree decomposition)
7. Scale to useful size, exploiting parallelsm and concurrency
8. Pay only a small abstraction cost in final assembly program.


In a computer algebra systems such as Macaulay2, Singular, Maple, Mathematica, we tell the computer the context, e.g. polynomial ring $R = \Q[x,y]$  and 
type in an expression such as $x^2 + 3xy + (x+y)^2$. 
The system performs some simplification according to the axioms of a free polynomial ring (or more generally, a Groebner basis computation in a quotient ring $R = \mathbb{Q}[x,y]/I $), and  displays something like $2x^2 + 5xy + y^2$, element of $R$.
Even a simplification like this something this trivial requires some thought for computational category theory!

From the modeling side, we want something like MATLAB, NumPy, R, but that:  

* allows a higher level of abstraction in describing algorithms,
* can handle more types of ``data'' than matrices of floats or probability distributions, and 
* treats morphism expressions as first class to enable rewriting, syntax tricks.

We'd like to think that Computational category theory is the numerical linear algebra of the 21st century, and this is the first steps toward a system that makes that real.

Now: reducing an applied  math problem to numerical linear algebra means you can solve it using BLAS, LAPACK primitives, matrix decompositions, etc.

Future: reduce your uncertainty/information-processing applied math problem to (computational) category theory, solve it using generic engines and libraries with matching abstractions.


# Design Principles
====================

* Today: some {\bf design principles} toward such a system.
* Can be implemented in any programming language with suitable features.

  *  Needed are typeclasses/traits/interfaces and, for performance, a means for zero or low cost abstraction 
  * so JIT and AOT languages with modern type systems are preferred
  * building in Julia, exploring Scala, Rust, maybe Python (what would you use?)

* Typeclasses/Traits represent {\em doctrines}: monoidal category, compact closed category, well-supported compact closed category,... and describe the {\em common interface} available to manipulate any particular category 


Everything the computer does is represented as one of five modular components:

* a **doctrine** (e.g.\ ``compact closed category'')
* an instance or implementation of a doctrine (e.g. matrices or relations as CCC):

  * a **morphism term** or word (e.g.\ $f \ot (g \circ \delta_A \circ h)$) in a free language, or 
  * a concrete **value** in an implementation (e.g.\ $\begin{pmatrix}1 & 3\\4 & 5 \end{pmatrix}$)  

* a **representation** (a functor) between implementations (usually free $\rightarrow$ concrete, e.g.\ a binding $f = \begin{pmatrix}1 & 3\\4 & 5 \end{pmatrix}$) for each symbol)
* **algorithms** are expressed in terms of the defining methods of the doctrine (e.g.\ $\otimes$, $\delta$) or operadically

From the modeling perspective, there are five parts to a Cateno model.

* **Morphism Term:** a human-readable *qualitative model*, captured by a labeled generalized graph;  fixes the relationships, *suggests* qualitative rules and syntax of the model
* **Doctrine:** formal *categorical syntax* constraining the quantitative models of uncertainty that can be attached, rewrite rules, available constructions
* **Value:** a machine-processed *quantitative model* in which  the graph is interpreted and the data summarized, e.g. probabilistically as a Bayesian network, in Hilbert space for a quantum circuit, or with rate constants in a chemical reaction network
* **Representation:** the *interpretation* assigning quantitative meaning to the qualitative description (generalizing the mathematical idea of a representation of a quiver or algebra)
* **Algorithms**, categorically expressed, for processing and analyzing data.  Make quantitative predictions,  choose the model which best explains a given system (often a variant of belief propagation).


## About the name

The word cateno is a Latin verb that means "to chain together" or "to bind."  Working with Cateno involves chaining together lego-like pieces to make a larger model, and binding morphism variables in a representation.  The project is intended to help build bridges across disciplines by making their analogous models literally the same, so we like the fact that cateno is the root of the English word catenary, which suggests such a role. Finally it starts with "cat" just as category, although "category" is Greek in origin.
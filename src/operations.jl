const PREDICT_OPERATIONS = (:predict,
                            :predict_mode,
                            :predict_mean,
                            :predict_median,
                            :predict_joint)

const OPERATIONS = (PREDICT_OPERATIONS..., :transform, :inverse_transform)

const DOC_NEW_DATA =
    "Here `report` contains ancilliary byproducts of the computation, or "*
    "is `nothing`; `data` is a tuple of data objects, "*
    "generally a single object representing new observations "*
    "not seen in training. "


# # METHOD STUBS/FALLBACKS

"""
    LearnAPI.predict(model, fitted_params, data...)

Return `(ŷ, report)` where `ŷ` are the predictions, or prediction-like output (such as
probabilities), for a machine learning model `model`, with learned parameters
`fitted_params`, as returned by a preceding call to [`LearnAPI.fit`](@ref)`(model, ...)`.
$DOC_NEW_DATA


# New model implementations

$(DOC_IMPLEMENTED_METHODS(:predict))

If `performance_measureable = true`, then `ŷ` must be:

- either an array or table with the same number of observations as each element of `data`;
  it cannot be a lazy object, such as a `DataLoader`

- **target-like**; see  [`LearnAPI.paradigm`](@ref) for specifics.

Otherwise there are no restrictions on what `predict` may return, apart from what the
implementation itself promises, by making an optional [`LearnAPI.output_scitypes`](@ref)
declaration.

If `predict` is computing a target proxy, as defined in the MLJLearn documentation, then a
[`LearnAPI.target_proxy_kind`](@ref) declaration is required, as in

```julia
LearnAPI.target_proxy_kind(::Type{<:SomeModel}) = (predict=LearnAPI.Distribution,)
```

Do `LearnAPI.target_proxy_kind()` to list the available kinds.

By default, it is expected that `data` has length one. Otherwise,
[`LearnAPI.input_scitypes`](@ref) must be overloaded.

See also [`LearnAPI.fit`](@ref), [`LearnAPI.predict_mean`](@ref),
[`LearnAPI.predict_mode`](@ref), [`LearnAPI.predict_median`](@ref).

"""
function predict end

function DOC_PREDICT(reducer)
    operation = Symbol(string("predict_", reducer))
    extra = DOC_IMPLEMENTED_METHODS(operation, overloaded=true)
    """
        LearnAPI.predict_$reducer(model, fitted_params, data...)

    Same as [`LearnAPI.predict`](@ref) except replaces probababilistic predictions with
    $reducer values.

    # New model implementations

    A fallback broadcasts `$reducer` over the first return value `ŷ` of
    `LearnAPI.predict`. An algorithm that computes probabilistic predictions may already
    need to predict mean values, and so overloading this method might enable a performance
    boost.

    $extra

    See also [`LearnAPI.predict`](@ref), [`LearnAPI.fit`](@ref).

    """
end

for reducer in [:mean, :median]
    operation = Symbol(string("predict_", reducer))
    docstring = DOC_PREDICT(reducer)
    quote
        "$($docstring)"
        function $operation(args...)
            distributions, report = predict(args...)
            yhat = $reducer.(distributions)
            return (yhat, report)
        end
    end |> eval
end

"""
    LearnAPI.predict_joint(model, fitted_params, data...)

For a supervised learning model, return `(d, report)`, where `d` is a *single* probability
distribution for the sample space ``Y^n``, where ``Y`` is the space in which the target
variable associated with `model` takes its values. Here `n` is the number of observations
in `data`.  Here `fitted_params` are the model's learned parameters, as returned by a
preceding call to [`LearnAPI.fit`](@ref). $DOC_NEW_DATA.

While the interpretation of this distribution depends on the model, marginalizing
component-wise will generally deliver *correlated* univariate distributions, and these will
generally not agree with those returned by `LearnAPI.predict`, if also implemented.

# New model implementations

Only implement this method if `model` has an associated concept of target variable, as
defined in the LearnAPI.jl documentation. A trait declaration
[`LearnAPI.target_proxy_kind`](@ref), such as

```julia
LearnAPI.target_proxy_kind(::Type{SomeModel}) = (predict_joint=JointSampleable(),)
```

is required. Here the possible kinds of target proxies are `LearnAPI.Sampleable`,
`LearnAPI.Distribution`, and `LearnAPI.LogDistribution`.

$(DOC_IMPLEMENTED_METHODS(:predict_joint)).

See also [`LearnAPI.fit`](@ref), [`LearnAPI.predict`](@ref).

"""
function predict_joint end

"""
    LearnAPI.transform(model, fitted_params, data...)

Return `(output, report)`, where `output` is some kind of transformation of `data`,
provided by `model`, based on the learned parameters `fitted_params`, as returned by a
preceding call to [`LearnAPI.fit`](@ref)`(model, ...)` (which could be `nothing` for
models that do not generalize to new data, such as "static transformers"). $DOC_NEW_DATA


# New model implementations

$(DOC_IMPLEMENTED_METHODS(:transform))

See also [`LearnAPI.inverse_transform`](@ref), [`LearnAPI.fit`](@ref),
[`LearnAPI.predict`](@ref),

"""
function transform end

"""
    LearnAPI.inverse_transform(model, fitted_params, data)

Return `(data_inverted, report)`, where `data_inverted` is valid input to the call

```julia
LearnAPI.transform(model, fitted_params, data_inverted)
```
$DOC_NEW_DATA

Typically, the map

```julia
data -> first(inverse_transform(model, fitted_params, data))
```

will be an inverse, approximate inverse, right inverse, or approximate right inverse, for
the map

```julia
data -> first(transform(model, fitted_params, data))
```

For example, if `transform` corresponds to a projection, `inverse_transform` is the
corresponding embedding.


# New model implementations

$(DOC_IMPLEMENTED_METHODS(:transform))

See also [`LearnAPI.fit`](@ref), [`LearnAPI.predict`](@ref),

"""
function inverse_transform end

function save end
function restore end
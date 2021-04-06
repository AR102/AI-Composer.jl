module NeuronalNetwork

if ("main.jl" in readdir()) == false
    cd("src")
end

# Packages
    println("This may take a very long time on first startup, please be patient and don't interrupt the process.\n")
    println("Installing packages if necessary...")
    import Pkg
    # Read installed packages
    deps = Pkg.dependencies()
    installs = Dict{String, VersionNumber}()
    for (uuid, dep) in deps
        dep.is_direct_dep || continue
        dep.version === nothing && continue
        installs[dep.name] = dep.version
    end
    # Check if packages are installed and install them when necessary
    if haskey(installs, "Gtk")
        println("   \"Gtk\" already installed")
    else
        println("   Installing \"Gtk\"...")
        Pkg.add("Gtk")
        println("   \"Gtk\" installed.")
    end
    if haskey(installs, "Graphics")
        println("   \"Graphics\" already installed")
    else
        println("   Installing \"Graphics\"...")
        Pkg.add("Graphics")
        println("   \"Graphics\" installed.")
    end
    if haskey(installs, "CSFML")
        println("   \"CSFML\" already installed")
    else
        println("   Installing \"CSFML\"...")
        Pkg.add("CSFML")
        println("   \"CSFML\" installed.")
    end
    if haskey(installs, "JLD2")
        println("   \"JLD2\" already installed")
    else
        println("   Installing \"JLD2\"...")
        Pkg.add("JLD2")
        println("   \"Graphics\" installed.")
    end
    if haskey(installs, "MIDI")
        println("   \"MIDI\" already installed")
    else
        println("   Installing \"MIDI\"...")
        Pkg.add("MIDI")
        println("   \"MIDI\" installed.")
    end
    if haskey(installs, "FileIO")
        println("   \"FileIO\" already installed")
    else
        println("   Installing \"FileIO\"...")
        Pkg.add("FileIO")
        println("   \"FileIO\" installed.")
    end
    if haskey(installs, "LibSndFile")
        println("   \"LibSndFile\" already installed")
    else
        println("   Installing \"LibSndFile\"...")
        Pkg.add("LibSndFile")
        println("   \"LibSndFile\" installed.")
    end
    if haskey(installs, "WAV")
        println("   \"WAV\" already installed")
    else
        println("   Installing \"WAV\"...")
        Pkg.add("WAV")
        println("   \"WAV\" installed.")
    end
    #=
    if haskey(installs, "Distributed")
        println("   \"Distributed\" already installed")
    else
        println("   Installing \"Distributed\"...")
        #=
        Pkg.add("Distributed")
        =#
        println("UPDATE!!!")
        println("   \"Distributed\" installed.")
    end
    =#
    println("Packages installed.")
    println("Compiling packages...")
    println("   Compiling \"Gtk\"...")
    using Gtk
    println("   \"Gtk\" compiled")
    println("   Compiling \"Graphics\"...")
    using Graphics
    println("   \"Graphics\" compiled")
    println("   Compiling \"CSFML\"...")
    using CSFML.LibCSFML
    println("   \"CSFML\" compiled")
    println("   Compiling \"JLD2\"...")
    using JLD2
    println("   \"JLD2\" compiled")
    println("   Compiling \"MIDI\"...")
    using MIDI
    println("   \"MIDI\" compiled")
    println("   Compiling \"FileIO\"...")
    #using FileIO
    using FileIO: load, save
    println("   \"FileIO\" compiled")
    println("   Compiling \"LibSndFile\"...")
    import LibSndFile
    println("   \"LibSndFile\" compiled")
    #=
    println("   Compiling \"Distributed\"...")
    using Distributed
    if nprocs() == 1
        addprocs(4)
    end
    @everywhere using Distributed
    println("   \"Distributed\" compiled")
    =#
    println("   Compiling \"WAV\"...")
    using WAV
    println("   \"WAV\" compiled")
    println("Packages Compiled.")
    println("Sarting app...")
    #=
    println("Importing packages...")
    #using PyPlot  #, LoopVectorization
    println("Packages imported.")
    =#

# Network structure
    # Neuron:
    # A Neuron consists of a netinput (activation before the sigmoid-function) and an activation-level (activation after sigmoid-function)
    mutable struct Neuron
        netinput::Float64
        activation::Float64
        δ::Float64
        bias::Float64
    end
    
    # Layer
    # A Layer consists of the neurons it contains and a bias
    mutable struct Layer
        neurons::Array{Neuron,1}
    end


    # Network
    mutable struct Network
        # Contains all Layers in allLayers, all Weights in allWeights and all Inputs in allInputs
        allInputs::Array{Float64,1}
        allLayers::Array{Layer,1}
        allWeights::Array{Array{Float64,2},1}
    end

    #   include(NeuronalNetwork)
    # Training data
    mutable struct TrainingData
        inputs::Array{Array{Float64,1}}
        outputs::Array{Array{Float64,1}}
    end

    # A Note
    mutable struct Note2
        pitch :: Int
        position :: Int
        duration :: Int
    end

    # Create network structure
    function createNetworkStructure(inputAmount::Int, neuronsInLayer::Array{Int})
        # Returns a network full of 0.0. inputAmount specifies the amount of inputs, neuronsInLayer the amount of Layers and how many neurons they each contain. 
        # E.g.: inputAmount=10, neuronsInLayer=[5, 6, 1] creates a network with 10 input neurons, 5 neurons in the first hidden layer, 6 neurons in the second hidden layer and 1 neuron in the output layer
        
        allInputs = zeros(Float64, inputAmount)
        allLayers = []
        for i = 1:length(neuronsInLayer)
            neurons = []
            for i2 = 1:neuronsInLayer[i]
                push!(neurons, Neuron(0.0, 0.0, 0.0, 2 * rand() - 1))
            end
            push!(allLayers, Layer(neurons))
        end

        #oneWeights = 4*rand(inputAmount,neuronsInLayer[1]) .- 2
        #oneWeights = 20*rand(inputAmount,neuronsInLayer[1]) .- 10
        oneWeights = 2*rand(inputAmount,neuronsInLayer[1]) .- 1

        allWeights = [oneWeights]
        for i = 2:length(neuronsInLayer)
            #oneWeights = 4 * rand(neuronsInLayer[i-1], neuronsInLayer[i]) .- 2
            #oneWeights = 20 * rand(neuronsInLayer[i-1], neuronsInLayer[i]) .- 10
            oneWeights = 2 * rand(neuronsInLayer[i-1], neuronsInLayer[i]) .- 1

            push!(allWeights, oneWeights)
        end
        return Network(allInputs, allLayers, allWeights)
    end

# Constants
    # const ϵ = 0.005 # the learning rate

# Mathematical functions
    # Sigmoid funtion
    function sig(x)
        # the activation function; it takes a number and returns the output of the sigmoid-function for it
        return 1 / (1 + exp(-x))  # using built-in exponential function as 
    end

    function sig(x,a) #the activation function; it takes a number and returns the output of the sigmoid-function for it
        return 1 / (1 + exp(-x/a))  # better use the built-in exponential function instead of ℯ^-x
    end

    function invsig(x,a)
        round(Int, -a*log(1/x - 1))
    end
    
    # Derivative of the sigmoid function
    function δSig(x)
        return sig(x) * (1 - sig(x))
    end

# Visualization functions
    function printNetworkStructure(netti)
        println("The input layer: ")
        println(length(netti.allInputs), " input(s)")
        println(" ")
        println("The hidden layer(s): ")
        for i = 1:length(netti.allLayers)-1
            println(length(netti.allLayers[i].neurons), " neuron(s)")
        end
        println(" ")
        println("The output layer: ")
        print(length(netti.allLayers[length(netti.allLayers)].neurons), " neuron(s)")
        println(" \n ")
        for i = 1:length(netti.allWeights)
            #println("The weights between Layer ", netti.allWeights[i].betweenLayers[1], " and ", netti.allWeights[i].betweenLayers[2], ":")
            println(length(netti.allWeights[i])-1, " weight(s)", " \n")
        end
    end

    function updateProgress(status, max, cost)
        newProgress = status * (100 / max)
        for i = 1:18
            print("\b")
        end
        print("[")
        bars = 0
        progress = newProgress
        while progress >= 10
            progress -= 10
            bars += 1
        end
        for i = 1:bars
            print("—")
        end
        for i = bars:9
            print(" ")
        end
        print("] ", convert(Int, round(newProgress)), "  ")
    end

# Network functions

function saveNetwork(path, network)
    save(path, "network", network)
    #@save path network
end


function loadNetwork(path)
    return load(path, "network")
    #@load "saves/tonleiter_network.jld2" network
    #return network
    #return JLD.load(path, "Main.N.network")
end

function forwardPass1!(network, smallLayer, features)
#function forwardPass1!(network, inputs=nothing)
    #if inputs !== nothing
    #    setInputs!(network, inputs)
    #end

    #=
    for i = 1:length(network.allLayers[1].neurons)
        sum = 0
        for ii = 1:length(network.allInputs)
            sum += network.allInputs[ii] * network.allWeights[1][ii, i]
        end
        sum += network.allLayers[1].neurons[i].bias
        
        network.allLayers[1].neurons[i].netinput = sum
        network.allLayers[1].neurons[i].activation = sig(sum)
    end
    =#

    #smallLayer = 2

    for i = 1:length(network.allLayers[smallLayer].neurons)
        network.allLayers[smallLayer].neurons[i].activation = features[i]
    end

    for i = smallLayer+1:length(network.allLayers)
        for ii = 1:length(network.allLayers[i].neurons)
            sum = 0
            for i3 = 1:length(network.allLayers[i-1].neurons)
                sum += network.allLayers[i-1].neurons[i3].activation * network.allWeights[i][i3, ii]
            end
            sum += network.allLayers[i].neurons[ii].bias
            network.allLayers[i].neurons[ii].netinput = sum
            network.allLayers[i].neurons[ii].activation = sig(sum)
        end
    end
    #return network
end

function forwardPass!(network, inputs=nothing)
    if inputs !== nothing
        setInputs!(network, inputs)
    end

    for i = 1:length(network.allLayers[1].neurons)
        sum = 0
        for ii = 1:length(network.allInputs)
            sum += network.allInputs[ii] * network.allWeights[1][ii, i]
        end
        sum += network.allLayers[1].neurons[i].bias
        
        network.allLayers[1].neurons[i].netinput = sum
        network.allLayers[1].neurons[i].activation = sig(sum)
    end


    for i = 2:length(network.allLayers)
        for ii = 1:length(network.allLayers[i].neurons)
            sum = 0
            for i3 = 1:length(network.allLayers[i-1].neurons)
                sum += network.allLayers[i-1].neurons[i3].activation * network.allWeights[i][i3, ii]
            end
            sum += network.allLayers[i].neurons[ii].bias
            network.allLayers[i].neurons[ii].netinput = sum
            network.allLayers[i].neurons[ii].activation = sig(sum)
        end
    end
    #return network
end


function setInputs!(network, inputs)
    length(inputs) == length(network.allInputs) ? nothing : error("More/Less inputs given than predefined in network.allInputs")
    for i = 1:length(network.allInputs)
        network.allInputs[i] = inputs[i]
    end
    #return network
end

function δ(nl::Int, pos::Int, network, supposedOutputs) # supposedOutputs::Array{Float64, 1}
    # nl : index of the layer
    # pos : position in layer
    layer = network.allLayers[nl]
    neuron = layer.neurons[pos]
    if nl == length(network.allLayers) # output layer
        result = δSig(neuron.netinput) * (supposedOutputs[pos] - neuron.activation)
    else
        sum = 0.0
        layer1 = network.allLayers[nl+1]
        for i = 1:length(layer1.neurons)
            sum += layer1.neurons[i].δ * network.allWeights[nl+1][pos, i]
        end
        result = sum * δSig(neuron.netinput)
    end
    return result
end

# Calculate Δ-value for a weight
function ΔW(nl1, pos1, nl2, pos2, network, ϵ, supposedOutputs) # supposedOutputs::Array{Float64, 1}
    # nl1, nl2   : index of layer 1 and 2
    # pos1, pos2 : position in layer 1 and 2
    network.allLayers[nl2].neurons[pos2].δ = δ(nl2, pos2, network, supposedOutputs)
    if nl1 == 0
        return (network, ϵ * network.allLayers[nl2].neurons[pos2].δ * network.allInputs[pos1])
    else
        return (network, ϵ * network.allLayers[nl2].neurons[pos2].δ * network.allLayers[nl1].neurons[pos1].activation)
    end
end

# Calculate Δ-value for a bias
function Δb(nl, pos, network, ϵ, supposedOutputs)
    # nl : index of the layer
    # pos : position in layer
    return ϵ * δ(nl, pos, network, supposedOutputs) # *1 can be ignored
end

function backpropagation!(network, tr_input, tr_output, ϵ)   
    # do backpropagation for a single input    
    setInputs!(network, tr_input)
    forwardPass!(network)
    for j = length(network.allLayers): -1 : 1
        (length1,length2) = size(network.allWeights[j])
        for n2 = 1:length2
            for n1 = 1:length1
                network, outputΔW = ΔW(j-1, n1, j, n2, network, ϵ, tr_output)
                network.allWeights[j][n1,n2] += outputΔW
            end
        network.allLayers[j].neurons[n2].bias += Δb(j, n2, network, ϵ, tr_output)
        end
    end
end

function getCost(network, training_data)
    sum = 0.0
    for i = 1:length(training_data.inputs)
        forwardPass!(network, training_data.inputs[i])
        output_layer = network.allLayers[end] 
        for i2 = 1:length(training_data.outputs[i])
            #sum += (network.allLayers[length(network.allLayers)].neurons[i2].activation - training_data.outputs[i][i2])^2
            sum += (output_layer.neurons[i2].activation - training_data.outputs[i][i2])^2
        end
    end
    return sum/(length(training_data.inputs)*length(training_data.outputs[1]))
end

function optimize!(network, training_data, ϵ)
    println("Doing backpropagations -> \"learning\"...")
    costs = []
    cost = 0
    updateProgress(0, 100, cost)
    niter = 100
    niter = 10000
    niter = 50000
    niter = 100000
    for i = 1:100
        for i = 1:niter
            ind = rand(1: length(training_data.inputs)) # take a random input
            input = training_data.inputs[ind]
            output = training_data.outputs[ind]
            backpropagation!(network, input, output, ϵ)
        end
        cost = getCost(network, training_data)
        println(cost)
        push!(costs, cost)
        updateProgress(i, 100, costs[end])
        #println("costs ", costs[end])
        #save_network(network)
        plot_costs(costs)
        testNetwork(training_data, network)

        ## show result
        # println()
        # println(training_data.outputs[end])
        # n = network.allLayers[end].neurons  # vector of neurons in output layer
        # println(map(x->x.activation, n))

    end
    save_network(network)
end

function plot_costs(costs)
    x = 1:length(costs)

    figure("Kostenentwicklung"*MODI)
    clf()
    subplot(3,1,1)
    plot(x, log10.(costs), "-*")
    xlabel("iterations")
    ylabel("cost")
    subplot(3,1,2)
    plot(log10.(x), log10.(costs), "*-")
    xlabel("iterations")
    ylabel("cost")
    subplot(3,1,3)
    plot(x, costs, "-*")
    xlabel("Iterationen")
    ylabel("Cost")
end


function save_network(network)
    #filepath = "saves/network1.jld2"
    filepath = FILENET
    println("Saving network at $filepath")
    saveNetwork(filepath, network)
end

# menu = "load"

function learning(training_data, eps)
    println("Creating network structure...")
    ninputs = length(training_data.inputs[1])
    noutputs = length(training_data.outputs[1])

    
    #network = createNetworkStructure(ninputs, [INNER_NEURONS, noutputs])
    
    network = createNetworkStructure(ninputs, [20, INNER_NEURONS, 20, noutputs])

    #network = createNetworkStructure(ninputs, [50, 25, INNER_NEURONS, 25, 50, noutputs])
    
    #network = createNetworkStructure(ninputs, [60, 30, noutputs])
    #network = loadNetwork("saves/tonleiter_network.jld2")
    printNetworkStructure(network)
    println("Network structure created.")


    optimize!(network, training_data, ϵ)
    println("Backpropagations done.")

    return network
end

function print_notes(notes)
    for note in notes
        println(note)
    end
end

function make_trainingsdata()
   
    trainingsdata = TrainingData([],[])
    d = load("saves/blues_licks.jld2", "licks")
    #@load "saves/blues_licks.jld2"
    for i = 1:length(d)
        activations = vec(reshape(d[i], 1, :))
        push!(trainingsdata.inputs, activations)
        push!(trainingsdata.outputs, activations)
    end
    #=
    for i = 1:100
        push!(trainingsdata.inputs, rand(3))
        push!(trainingsdata.outputs, rand(3))
    end
    =#
    return trainingsdata
end

function make_test_notes_from_midi(len, filename, track)

    #midi = readMIDIFile("songs/Bach-1.mid")
    midi = readMIDIFile(filename)
    track = midi.tracks[track]
    #println("Notes of track $(trackname(track)):")
    notes = getnotes(track, midi.tpq)
    if len != 0
        notes = notes[1:len]
    end
    #notes = get_song(notes, 40)
    notes
end

function notes2bitArr(notes)
    #=
    pitches = map(x->Int(x.pitch), notes)
    pitches .-= 30

    positions = map(x->Float64(x.position), notes)
    positions ./= 64
    positions = map(x->round(Int, x), positions)
    positions .-= positions[1]-1
    output = zeros(66, positions[end])
    for i = 1:length(positions)
        output[pitches[i], positions[i]] = 1.0
    end

    #figure("song")
    #clf()
    #imshow(output)
    #show()
    return output
    =#
    bar = []
    scale = Dict(60=>1,
    62=>2,
    63=>3,
    64=>4,
    65=>5,
    66=>6,
    67=>7,
    69=>8,
    70=>9,
    71=>10,
    72=>11,
    74=>12,
    75=>13,
    76=>14,
    77=>15,
    78=>16,
    79=>17,
    81=>18,
    82=>19,
    83=>20,
    84=>21)

    for i = 1:length(notes)

        foo = zeros(Int, 3)
        foo[1] = scale[notes[i].pitch]
        foo[2] = round(Int, notes[i].position/240)+1
        foo[3] = round(Int, (notes[i].position + notes[i].duration)/240)

        push!(bar, foo)
    end
    output = zeros(21, 16)
    for foo in bar
        for i = foo[2]:foo[3]
            output[foo[1], i] = 1
        end
    end
    figure("ai")
    clf()
    imshow(output)
    filepath = "saves/blues_licks.jld2"
    licks = load(filepath, "licks")
    #@load filepath
    licks[length(licks)+1] = output
    #save(filepath, "licks", licks)
    @save filepath licks
    

    print_notes(bitArr2notes(output, 0.5))
end

function bitArr2notes(input, bias)
    arr = copy(input)
    scale = [0,2,3,4,5,6,7,9,10,11,12,14,15,16,17,18,19,21,22,23,24]
    notes = Notes()
    for row in 1:size(arr)[1]
        for column in 1:size(arr)[2]
            if arr[row,column] > bias
                i = 1
                while column+i <= 16
                    if arr[row, column+i] > bias
                        i+=1
                        arr[row, column+i-1] = 0.0
                    else
                        break
                    end
                end
                push!(notes, Note(scale[row]+60, 96, 480*(column-1), 480*i))
            end
        end
    end

    file = MIDIFile()
    track = MIDITrack()
    addnotes!(track, notes)
    addtrackname!(track, "simple track")
    push!(file.tracks, track)
    writeMIDIFile("test.mid", file)
    return notes
end

function testNetwork(trainingdata, network = loadNetwork(FILENET))
    r = rand(1:length(trainingdata.inputs))
    in = trainingdata.inputs[r]
    out = trainingdata.outputs[r]
    
    forwardPass!(network, in)
    est = map(x -> x.activation, network.allLayers[end].neurons)
    error = abs.(est .- out)
    
    est = reshape(est, 21, 16)
    out = reshape(out, 21, 16)
    error = reshape(error, 21, 16)

    figure("midis"*MODI)
    clf()
    subplot(1,3,1)
    #figure("original")
    imshow(out)

    subplot(1,3,2)
    #figure("ai")
    imshow(est)

    subplot(1,3,3)
    #figure("error")
    imshow(error)


end

function appendMotive(motive, bar, notes)
    n = copy(notes)
    m = copy(motive)
    for i = 1:length(m) 
        m[i].position += bar*8*960
    end
    for i2 in m
        push!(n, i2)
    end
    return n
end

function compose(smallLayer)
    network = loadNetwork(FILENET)

    motives = []
    for i = 1:3
        #forwardPass1!(network, smallLayer) # Fixen!!
        act = map(x -> x.activation, network.allLayers[end].neurons)
        act = reshape(act, (21, 16))
        foo = bitArr2notes(act, 0.2)
        while length(foo) < 8 || length(foo) > 25
            #forwardPass1!(network, smallLayer) # Fixen!!
            act = map(x -> x.activation, network.allLayers[end].neurons)
            act = reshape(act, (21, 16))
            foo = bitArr2notes(act, 0.2)
        end
        push!(motives, foo)
    end
    notes = Notes()
    for i in motives[1]
        push!(notes, i)
    end
    println(motives)
    notes = appendMotive(motives[2], 1, notes)
    notes = appendMotive(motives[1], 2, notes)
    notes = appendMotive(motives[3], 3, notes)
    notes = appendMotive(motives[2], 4, notes)
    notes = appendMotive(motives[1], 5, notes)

    file = MIDIFile()
    track = MIDITrack()
    addnotes!(track, notes)
    addtrackname!(track, "simple track")
    push!(file.tracks, track)
    writeMIDIFile("test.mid", file)
end

#=
function test(trainingsdata, network = loadNetwork(FILENET))
    acts = []
    for i = 1:length(trainingdata.inputs)
        forwardPass!(network, trainingdata.inputs[i])
        latent_space = map(x-)
    end
end
=#

N = 16
M = 200
relative_pitches = false
ϵ = 0.02 # the learning rate

FILENET = "saves/network_L2_n20_5.jld2"   # one layer with 4 neurons
network = loadNetwork(FILENET)
const INNER_NEURONS = 5
const MODI = "3"

#=
function playBitArr(arr)
    frequenzys = [
        261,
        293,
        311,
        329,
        349,
        369,
        391,
        440,
        466,
        493,
        523,
        587,
        622,
        659,
        698,
        739,
        783,
        880,
        932,
        987,
        1046
    ]
    fs = 8e3
    #t = 0.0:1/fs:prevfloat(1.0)
    t = 0.0:1/fs:prevfloat(4.0)
    wavwrite(sin.(0 * t[1:1]) , "example.wav", Fs=fs)
    for column in 1:size(arr)[2]
        y = sin.(0 * t[1:2000])
        for row in 1:size(arr)[1]
             y += sin.(2pi * frequenzys[row] * t[((column-1)*2000+1):column * 2000]) * (arr[row, column]/5)
        end
        wavappend(y, "example.wav")
        #println(y)
    end
    y, fs = wavread("example.wav")
    println(typeof(y))
    wavplay(y, fs)
end
=#


# ***MUSIC PLAYBACK C4 - C6

function midi2wav_name(n_name)
    numbers = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    note = n_name[1]
    ind = 2
    for i = 2:length(n_name)
        if n_name[ind] == '♯'
            note = note * "#"
            ind += 2
        elseif n_name[ind] in numbers
            note = note * "_" * n_name[ind]
        end
        ind += 1
    end
    return Symbol(note)
end

note_dict = Dict{Symbol,Tuple{Array{Float64,2},Float32,UInt16,Array{WAVChunk,1}}}()

note_alphabet = ["C", "D", "E", "F", "G", "A", "B"]
octaves = [4, 5]

for i2 in octaves
    for i3 in note_alphabet
        note_dict[Symbol(i3 * "_" * string(i2))] = wavread("notes/" * i3 * "_" * string(i2) * ".wav")
        if i3 == "C" || i3 == "D" || i3 == "F" || i3 == "G" || i3 == "A"
            note_dict[Symbol(i3 * "#" * "_" * string(i2))] = wavread("notes/" * i3 * "#" * "_" * string(i2) * ".wav")
        end
    end
end
note_dict[:C_6] = wavread("notes/C_6.wav")
note_dict[:empty] = wavread("notes/empty.wav")

#=
function custom_isless_pos(n1, n2)
    return isless(n1.position, n2.position)
end

function sort_notes_by_position(notes)
    if isempty(notes)
        return notes
    else
        notes_a = [notes...]
        println(notes_a)
        sort!(notes_a; lt = custom_isless_pos)
        return Notes(notes_a)
    end
end
=#


function shorten_note(note, duration)
    #dur = (length(note[:, 1]) / 16) * duration
    dur = (length(note[:, 1]) / 16) * duration
    return note[1:round(Int, dur), :]
end


#=
function shorten_note(note, duration)
    #dur = (length(note[:, 1]) / 16) * duration
    note_s = Float64[]
    stepsize = Int(16 / duration)
    println(stepsize)
    i = 1
    while i <= size(note)[1]
        push!(note_s, note[:, 1][i])
        i += stepsize
    end
    #dur = (length(note[:, 1]) / 16) * duration
    #return note[1:round(Int, dur), :]
    return [note_s note_s]
end
=#

function getWavBitArr(bit_arr)
    arr = copy(bit_arr)
    scale = [0,2,3,4,5,6,7,9,10,11,12,14,15,16,17,18,19,21,22,23,24]
    bias = 0.5
    wav = zeros(176400, 2)
    #println(size(wav))
    for column = 1:size(arr)[2]
        for row = 1:size(arr)[1]
            if arr[row, column] > bias
                i = 1
                while column + i <= 16
                    if arr[row, column + i] > bias
                        arr[row, column + i] = 0.0
                        i += 1
                    else
                        break
                    end
                end
                midi_note_n = pitch_to_name(scale[row] + 60)
                wav_note_n = midi2wav_name(midi_note_n)
                #println("Wav dims: ", size(wav[(column - 1) * 11025 + 1 : (column + i - 1) * 11025, :]))
                #println("Note dims: ", size(shorten_note(note_dict[wav_note_n][1], i)))
                wav[(column - 1) * 11025 + 1 : (column + i - 1) * 11025, :] .+= shorten_note(note_dict[wav_note_n][1], i)
            end
        end
    end

    #wavplay(wav, note_dict[:C_5][2])
    return wav
end

#=
@everywhere function playback_notes(notes, notes_i, note_amount)
    note = notes[notes_i]
    dur = Int((length(note_dict[note[1]][1][:, 1])/16) * note[2])
    #println(length)
    #con = last(readlines("ready.txt"))
    #ready = parse(Int, con)
    while last(readlines("ready.txt")) == "0"
        sleep(0.3)
    end
    println("Start note ", note[1])
    wavplay(note_dict[note[1]][1][1:dur, :], 44100)
    println("Finished note ", note[1])
end
=#


# ***GUI / USER BACKEND
# Constants weil die Dokumentation einfach nur unvollständig ist und ich keinen Bock habe immer wieder durch Ausprobieren die richtigen Werte rauszufinden
    # Für :halign
    const GTK_ALIGN_FILL = 0 # default
    const GTK_ALIGN_START = 1
    const GTK_ALIGN_END = 2
    const GTK_ALIGN_CENTER = 3
    # Für GtkScale()
    const h = false
    const v = true
    # Für GtkPositionType
    const GTK_POS_LEFT = 0
    const GTK_POS_RIGHT = 1
    const GTK_POS_TOP = 2 # default
    const GTK_POS_BOTTOM = 3
    # Für GdkEventButton.button
    const GTK_LEFT_CLICK = 1
    const GTK_MIDDLE_CLICK = 2
    const GTK_RIGHT_CLICK = 3

# Keyboard shortcuts
    # P = Play / Pause

main_win = GtkWindow("Neural Jazz") # Das Hauptfenster
maximize(main_win)
hbox = GtkBox(:h)       #
push!(main_win, hbox)   # Horizontale Aufteilung in zwei Bereiche
# Erster Bereich ("Spalte")
    vbox = GtkBox(:v)       #
    set_gtk_property!(vbox, :hexpand, true)
    push!(hbox, vbox)       # Vetikale Aufteilung in drei Bereiche
    # Erster Bereich ("Reihe")
        all_notes = @GtkCanvas()                            #
        set_gtk_property!(all_notes, :expand, true)         #
        set_gtk_property!(all_notes, :margin_left, 10)
        set_gtk_property!(all_notes, :margin_right, 10)
        set_gtk_property!(all_notes, :margin_top, 10)
        set_gtk_property!(all_notes, :margin_bottom, 10)
        push!(vbox, all_notes)                              # Canvas zum plotten aller Noten
    # Zweiter Bereich ("Reihe")
        sureness_vbox = GtkBox(:v)
            sureness_slider = GtkScale(h, 0:1)                 # Regler
            sureness_adj = GtkAdjustment(sureness_slider)       #
            set_gtk_property!(sureness_adj, :value, 0.5)        #
            set_gtk_property!(sureness_slider, :digits, 2)      #
            set_gtk_property!(sureness_slider, :hexpand, true)  #
        push!(vbox, sureness_slider)                        #
    # Dritter Bereich ("Reihe")
        played_notes = @GtkCanvas()                         # 
        set_gtk_property!(played_notes, :expand, true)      #
        set_gtk_property!(played_notes, :margin_left, 10)
        set_gtk_property!(played_notes, :margin_right, 10)
        set_gtk_property!(played_notes, :margin_top, 10)
        set_gtk_property!(played_notes, :margin_bottom, 10)
        push!(vbox, played_notes)                           # Canvas zum plotten der zu spielenden Noten
    # Vierter Bereich
        playing_progress = GtkScale(h, 0:16)
        playing_progress_adj = GtkAdjustment(playing_progress)
        set_gtk_property!(playing_progress, :draw_value, false)
        #set_gtk_property!(playing_progress, :digits, 0)
        #set_gtk_property!(playing_progress, :round_digits, 0)
        set_gtk_property!(playing_progress, :sensitive, false)
        set_gtk_property!(playing_progress, :focus_on_click, false)
        push!(vbox, playing_progress)

        curr_slider_changing = false

        function button_press(widget, event)
            global prev_state = sfMusic_getStatus(cursong)
            global curr_slider_changing = true
            sfMusic_pause(cursong)
        end

        button_press_s = signal_connect(button_press, playing_progress, :button_press_event)

        @guarded function button_release(widget, event)
            sfMusic_setPlayingOffset(cursong, sfTime(round(Int, get_gtk_property(playing_progress_adj, :value, Float64) * 0.25 * 1000000)))
            if prev_state == sfPlaying
                sfMusic_play(cursong)
            end
            global curr_slider_changing = false
        end

        button_release_s = signal_connect(button_release, playing_progress, :button_release_event)
        
    # Fünfter Bereich

        play_hbox = GtkBox(:h)
        set_gtk_property!(play_hbox, :halign, GTK_ALIGN_CENTER)
        push!(vbox, play_hbox)

        b_play = GtkButton("Play")
        set_gtk_property!(b_play, :halign, GTK_ALIGN_CENTER)
        set_gtk_property!(b_play, :margin_bottom, 10)
        push!(play_hbox, b_play)

        @guarded function play(widget)
            global playing_module
            if isequal(playing_module, get_current_module()) == false
                global playing_module
                playing_module = get_current_module()
                curwav = getWavBitArr(playing_module)
                save("example.ogg", curwav; samplerate=44100)
                global cursong = sfMusic_createFromFile("example.ogg")
            end
            if sfMusic_getPlayingOffset(cursong).microseconds == 0
                sfMusic_setPlayingOffset(cursong, sfTime(1))
            end
            set_gtk_property!(b_play, :sensitive, false)
            sfMusic_play(cursong)
            set_gtk_property!(b_pause, :sensitive, true)
        end
        play_s = signal_connect(play, b_play, :clicked)

        b_pause = GtkButton("Pause")
        set_gtk_property!(b_pause, :halign, GTK_ALIGN_CENTER)
        set_gtk_property!(b_pause, :margin_bottom, 10)
        set_gtk_property!(b_pause, :sensitive, false)
        push!(play_hbox, b_pause)

        @guarded function pause(widget)
            #signal_handler_disconnect(widget, pause_s)
            set_gtk_property!(b_pause, :sensitive, false)
            sfMusic_pause(cursong)
            set_gtk_property!(b_play, :sensitive, true)
            #global resume_s = signal_connect(resume, b_pause, :clicked)
        end

        pause_s = signal_connect(pause, b_pause, :clicked)

        function pause_key(widget, event)
            if event.keyval == 112 # 112 = P
                if sfMusic_getStatus(cursong) == sfPlaying
                    pause(nothing)
                else
                    play(nothing)
                end
            end
        end

        pause_key_s = signal_connect(pause_key, main_win, :key_press_event)

        #=
        @guarded function resume(widget)
            println("RESUMED")
            signal_handler_disconnect(widget, resume_s)
            sfMusic_play(cursong)
            set_gtk_property!(widget, :label, "Pause")
            pause_s = signal_connect(pause, b_pause, :clicked)
        end
        =#

        b_reset = GtkButton("Reset")
        set_gtk_property!(b_reset, :halign, GTK_ALIGN_CENTER)
        set_gtk_property!(b_reset, :margin_bottom, 10)
        set_gtk_property!(b_reset, :sensitive, false)
        push!(play_hbox, b_reset)

        @guarded function reset_prog(widget)
            sfMusic_stop(cursong)
            #set_gtk_property!(playing_progress_adj, :value, 0.0)
            #=
            if get_gtk_property(b_pause, :label, String) == "Resume"
                signal_handler_disconnect(widget, resume_s)
                sfMusic_play(cursong)
                set_gtk_property!(widget, :label, "Pause")
                pause_s = signal_connect(pause, b_pause, :clicked)
            end
            =#
        end

        reset_s = signal_connect(reset_prog, b_reset, :clicked)

# Zweiter Bereich ("Spalte")
    vbox2 = GtkBox(:v)
    set_gtk_property!(vbox2, :spacing, 10)
    set_gtk_property!(vbox2, :margin_bottom, 10)
    set_gtk_property!(vbox2, :hexpand, false)
    push!(hbox, vbox2)
    # Nullter Bereich
        slider_title_l = GtkLabel("<span size=\"x-large\" weight=\"bold\">Features:</span>")
        set_gtk_property!(slider_title_l, :use_markup, true)
        set_gtk_property!(slider_title_l, :halign, GTK_ALIGN_START) # 1 = :GTK_ALIGN_START
        set_gtk_property!(slider_title_l, :margin_left, 10)
        
        set_gtk_property!(slider_title_l, :margin_top, 10)
        push!(vbox2, slider_title_l)
    # Erster Bereich ("Reihe")
        slider_grid = GtkGrid()
        slider_1 = GtkScale(false, 0:1)
        slider_1_adj = GtkAdjustment(slider_1)
        set_gtk_property!(slider_1, :digits, 3)
        set_gtk_property!(slider_1_adj, :value, 0.5)
        set_gtk_property!(slider_1, :draw_value, true)
        set_gtk_property!(slider_1, :hexpand, true)
        #set_gtk_property!(slider_1, :vexpand, true)
        #set_gtk_property!(slider_1, :inverted, true)
        slider_grid[1, 1] = slider_1

        slider_2 = GtkScale(false, 0:1)
        slider_2_adj = GtkAdjustment(slider_2)
        set_gtk_property!(slider_2, :digits, 3)
        set_gtk_property!(slider_2_adj, :value, 0.5)
        set_gtk_property!(slider_2, :draw_value, true)
        set_gtk_property!(slider_2, :hexpand, true)
        #set_gtk_property!(slider_2, :vexpand, true)
        #set_gtk_property!(slider_2, :inverted, true)
        slider_grid[1, 2] = slider_2

        slider_3 = GtkScale(false, 0:1)
        slider_3_adj = GtkAdjustment(slider_3)
        set_gtk_property!(slider_3, :digits, 3)
        set_gtk_property!(slider_3_adj, :value, 0.5)
        set_gtk_property!(slider_3, :draw_value, true)
        set_gtk_property!(slider_3, :hexpand, true)
        #set_gtk_property!(slider_3, :vexpand, true)
        #set_gtk_property!(slider_3, :inverted, true)
        slider_grid[1, 3] = slider_3

        slider_4 = GtkScale(false, 0:1)
        slider_4_adj = GtkAdjustment(slider_4)
        set_gtk_property!(slider_4, :digits, 3)
        set_gtk_property!(slider_4_adj, :value, 0.5)
        set_gtk_property!(slider_4, :draw_value, true)
        set_gtk_property!(slider_4, :hexpand, true)
        #set_gtk_property!(slider_4, :vexpand, true)
        #set_gtk_property!(slider_4, :inverted, true)
        slider_grid[1, 4] = slider_4

        slider_5 = GtkScale(false, 0:1)
        slider_5_adj = GtkAdjustment(slider_5)
        set_gtk_property!(slider_5, :digits, 3)
        set_gtk_property!(slider_5_adj, :value, 0.5)
        set_gtk_property!(slider_5, :draw_value, true)
        set_gtk_property!(slider_5, :hexpand, true)
        #set_gtk_property!(slider_5, :vexpand, true)
        #set_gtk_property!(slider_5, :inverted, true)
        slider_grid[1, 5] = slider_5

        push!(vbox2, slider_grid)

        
        curwav = getWavBitArr(zeros(21, 16))
        save("example.ogg", curwav; samplerate=44100)
        curogg = load("example.ogg")
        cursong = sfMusic_createFromFile("example.ogg")
        

        function update_notes()
            features = [
                get_gtk_property(slider_1_adj, :value, Float64),
                get_gtk_property(slider_2_adj, :value, Float64),
                get_gtk_property(slider_3_adj, :value, Float64),
                get_gtk_property(slider_4_adj, :value, Float64),
                get_gtk_property(slider_5_adj, :value, Float64),
            ]
            forwardPass1!(network, 2, features)
            output = map(n -> n.activation, last(network.allLayers).neurons)
            output = reshape(output, (21, 16))
            draw_pattern(output, all_notes)
            limit = get_gtk_property(sureness_adj, :value, Float64)
            output = map(x -> x > limit ? 1.0 : 0.0, output)
            draw_pattern(output, played_notes)
            sfMusic_stop(cursong)
            set_gtk_property!(b_reset, :sensitive, true)
            set_gtk_property!(playing_progress, :sensitive, true)
        end

        function slider_updated(widget)
            update_notes()
        end

        update_connect_1 = signal_connect(slider_updated, slider_1, :value_changed)
        update_connect_2 = signal_connect(slider_updated, slider_2, :value_changed)
        update_connect_3 = signal_connect(slider_updated, slider_3, :value_changed)
        update_connect_4 = signal_connect(slider_updated, slider_4, :value_changed)
        update_connect_5 = signal_connect(slider_updated, slider_5, :value_changed)

    # Zweiter Bereich ("Reihe")
        b_randomize = GtkButton("Random Seed")
        set_gtk_property!(b_randomize, :margin_left, 10)
        set_gtk_property!(b_randomize, :margin_right, 10)
        push!(vbox2, b_randomize)
    # Dritter Bereich ("Reihe")
        b_save_m = GtkButton("Save current module")
        set_gtk_property!(b_save_m, :margin_left, 10)
        set_gtk_property!(b_save_m, :margin_right, 10)
        push!(vbox2, b_save_m)

    # Vierter Bereich ("Reihe")
        hbox_b_m_1 = GtkBox(:h)
        set_gtk_property!(hbox_b_m_1, :margin_top, 10)
        set_gtk_property!(hbox_b_m_1, :margin_left, 12)
        
        push!(vbox2, hbox_b_m_1)

        function get_current_module()
            features = [
                get_gtk_property(slider_1_adj, :value, Float64),
                get_gtk_property(slider_2_adj, :value, Float64),
                get_gtk_property(slider_3_adj, :value, Float64),
                get_gtk_property(slider_4_adj, :value, Float64),
                get_gtk_property(slider_5_adj, :value, Float64),
            ]
            forwardPass1!(network, 2, features)
            output = map(n -> n.activation, last(network.allLayers).neurons)
            output = reshape(output, (21, 16))
            limit = get_gtk_property(sureness_adj, :value, Float64)
            output = map(x -> x > limit ? 1.0 : 0.0, output)
            return output
        end

        all_modules = [Array{Float64}(undef, 0, 0), Array{Float64}(undef, 0, 0), Array{Float64}(undef, 0, 0), Array{Float64}(undef, 0, 0)]
        
        # Erster Bereich ("Spalte")
            b_m_1_label_t = GtkLabel("<span size=\"large\" weight=\"normal\">Module 1:  </span>")
            set_gtk_property!(b_m_1_label_t, :use_markup, true)
            push!(hbox_b_m_1, b_m_1_label_t)
        # Zweiter Bereich ("Spalte")
            b_m_1_label = GtkLabel("<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
            set_gtk_property!(b_m_1_label, :width_request, 50)
            set_gtk_property!(b_m_1_label, :use_markup, true)
            push!(hbox_b_m_1, b_m_1_label)
        # Dritter Bereich ("Spalte")
            b_m_1 = GtkButton("Keep as Module 1")
            set_gtk_property!(b_m_1, :margin_left, 10)
            set_gtk_property!(b_m_1, :margin_right, 10)
            push!(hbox_b_m_1, b_m_1)
        # Vierter Bereich ("Spalte")
            b_m_1_reset = GtkButton("Reset Module 1")
            set_gtk_property!(b_m_1_reset, :margin_left, 10)
            set_gtk_property!(b_m_1_reset, :margin_right, 10)
            set_gtk_property!(b_m_1_reset, :sensitive, false)
            push!(hbox_b_m_1, b_m_1_reset)
        # Fünfter Bereich ("Spalte")
            b_m_1_view = GtkButton("View")
            set_gtk_property!(b_m_1_view, :margin_left, 10)
            set_gtk_property!(b_m_1_view, :margin_right, 10)
            set_gtk_property!(b_m_1_view, :sensitive, false)
            #push!(hbox_b_m_1, b_m_1_view)

        @guarded function save_module_1(widget)
            set_gtk_property!(b_m_1, :sensitive, false)
            all_modules[1] = get_current_module()
            set_gtk_property!(b_m_1_reset, :sensitive, true)
            set_gtk_property!(b_m_1_view, :sensitive, true)
            if get_gtk_property(b_m_2_reset, :sensitive, Bool) && get_gtk_property(b_m_3_reset, :sensitive, Bool) && get_gtk_property(b_m_4_reset, :sensitive, Bool)
                set_gtk_property!(b_save_song, :sensitive, true)
                set_gtk_property!(b_save_song, :has_tooltip, false)
            end
            set_gtk_property!(b_m_1_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"green\">Saved</span>")
        end
        save_module_1_s = signal_connect(save_module_1, b_m_1, :clicked)

        function reset_module_1(widget)
            set_gtk_property!(b_m_1_reset, :sensitive, false)
            set_gtk_property!(b_m_1_view, :sensitive, false)
            all_modules[1] = Array{Float64}(undef, 0, 0)
            set_gtk_property!(b_m_1, :sensitive, true)
            set_gtk_property!(b_save_song, :sensitive, false)
            set_gtk_property!(b_save_song, :has_tooltip, true)
            set_gtk_property!(b_m_1_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
        end
        reset_module_1_s = signal_connect(reset_module_1, b_m_1_reset, :clicked)

        function view_module_1(widget)
            show_win = GtkWindow("Module 1")
            main_box = GtkBox(:v)
            push!(show_win, main_box)
            
        end
        view_module_1_s = signal_connect(view_module_1, b_m_1_view, :clicked)

    # Fünfter Bereich ("Reihe")
        hbox_b_m_2 = GtkBox(:h)
        set_gtk_property!(hbox_b_m_2, :margin_top, 10)
        set_gtk_property!(hbox_b_m_2, :margin_left, 12)
        push!(vbox2, hbox_b_m_2)
        # Erster Bereich ("Spalte")
            b_m_2_label_t = GtkLabel("<span size=\"large\" weight=\"normal\">Module 2:  </span>")
            set_gtk_property!(b_m_2_label_t, :use_markup, true)
            push!(hbox_b_m_2, b_m_2_label_t)
        # Zweiter Bereich ("Spalte")
            b_m_2_label = GtkLabel("<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
            set_gtk_property!(b_m_2_label, :width_request, 50)
            set_gtk_property!(b_m_2_label, :use_markup, true)
            push!(hbox_b_m_2, b_m_2_label)
        # Dritter Bereich ("Spalte")
            b_m_2 = GtkButton("Keep as Module 2")
            set_gtk_property!(b_m_2, :margin_left, 10)
            set_gtk_property!(b_m_2, :margin_right, 10)
            push!(hbox_b_m_2, b_m_2)
        # Vierter Bereich ("Spalte")
            b_m_2_reset = GtkButton("Reset Module 2")
            set_gtk_property!(b_m_2_reset, :margin_left, 10)
            set_gtk_property!(b_m_2_reset, :margin_right, 10)
            set_gtk_property!(b_m_2_reset, :sensitive, false)
            push!(hbox_b_m_2, b_m_2_reset)

        function save_module_2(widget)
            set_gtk_property!(b_m_2, :sensitive, false)
            all_modules[2] = get_current_module()
            set_gtk_property!(b_m_2_reset, :sensitive, true)
            if get_gtk_property(b_m_1_reset, :sensitive, Bool) && get_gtk_property(b_m_3_reset, :sensitive, Bool) && get_gtk_property(b_m_4_reset, :sensitive, Bool)
                set_gtk_property!(b_save_song, :sensitive, true)
                set_gtk_property!(b_save_song, :has_tooltip, false)
            end
            set_gtk_property!(b_m_2_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"green\">Saved</span>")
        end
        save_module_2_s = signal_connect(save_module_2, b_m_2, :clicked)

        function reset_module_2(widget)
            set_gtk_property!(b_m_2_reset, :sensitive, false)
            all_modules[1] = Array{Float64}(undef, 0, 0)
            set_gtk_property!(b_m_2, :sensitive, true)
            set_gtk_property!(b_save_song, :sensitive, false)
            set_gtk_property!(b_save_song, :has_tooltip, true)
            set_gtk_property!(b_m_2_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
        end
        reset_module_2_s = signal_connect(reset_module_2, b_m_2_reset, :clicked)
    # Sechster Bereich ("Reihe")
        hbox_b_m_3 = GtkBox(:h)
        set_gtk_property!(hbox_b_m_3, :margin_top, 10)
        set_gtk_property!(hbox_b_m_3, :margin_left, 12)
        push!(vbox2, hbox_b_m_3)
        # Erster Bereich ("Spalte")
            b_m_3_label_t = GtkLabel("<span size=\"large\" weight=\"normal\">Module 3:  </span>")
            set_gtk_property!(b_m_3_label_t, :use_markup, true)
            push!(hbox_b_m_3, b_m_3_label_t)
        # Zweiter Bereich ("Spalte")
            b_m_3_label = GtkLabel("<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
            set_gtk_property!(b_m_3_label, :width_request, 50)
            set_gtk_property!(b_m_3_label, :use_markup, true)
            push!(hbox_b_m_3, b_m_3_label)
        # Dritter Bereich ("Spalte")
            b_m_3 = GtkButton("Keep as Module 3")
            set_gtk_property!(b_m_3, :margin_left, 10)
            set_gtk_property!(b_m_3, :margin_right, 10)
            push!(hbox_b_m_3, b_m_3)
        # Vierter Bereich ("Spalte")
            b_m_3_reset = GtkButton("Reset Module 3")
            set_gtk_property!(b_m_3_reset, :margin_left, 10)
            set_gtk_property!(b_m_3_reset, :margin_right, 10)
            set_gtk_property!(b_m_3_reset, :sensitive, false)
            push!(hbox_b_m_3, b_m_3_reset)

        function save_module_3(widget)
            set_gtk_property!(b_m_3, :sensitive, false)
            all_modules[3] = get_current_module()
            set_gtk_property!(b_m_3_reset, :sensitive, true)
            if get_gtk_property(b_m_1_reset, :sensitive, Bool) && get_gtk_property(b_m_2_reset, :sensitive, Bool) && get_gtk_property(b_m_4_reset, :sensitive, Bool)
                set_gtk_property!(b_save_song, :sensitive, true)
                set_gtk_property!(b_save_song, :has_tooltip, false)
            end
            set_gtk_property!(b_m_3_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"green\">Saved</span>")
        end
        save_module_3_s = signal_connect(save_module_3, b_m_3, :clicked)

        function reset_module_3(widget)
            set_gtk_property!(b_m_3_reset, :sensitive, false)
            all_modules[1] = Array{Float64}(undef, 0, 0)
            set_gtk_property!(b_m_3, :sensitive, true)
            set_gtk_property!(b_save_song, :sensitive, false)
            set_gtk_property!(b_save_song, :has_tooltip, true)
            set_gtk_property!(b_m_3_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
        end
        reset_module_3_s = signal_connect(reset_module_3, b_m_3_reset, :clicked)
    # Siebter Bereich ("Reihe")
        hbox_b_m_4 = GtkBox(:h)
        set_gtk_property!(hbox_b_m_4, :margin_top, 10)
        set_gtk_property!(hbox_b_m_4, :margin_left, 12)
        push!(vbox2, hbox_b_m_4)
        # Erster Bereich ("Spalte")
            b_m_4_label_t = GtkLabel("<span size=\"large\" weight=\"normal\">Module 4:  </span>")
            set_gtk_property!(b_m_4_label_t, :use_markup, true)
            push!(hbox_b_m_4, b_m_4_label_t)
        # Zweiter Bereich ("Spalte")
            b_m_4_label = GtkLabel("<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
            set_gtk_property!(b_m_4_label, :width_request, 50)
            set_gtk_property!(b_m_4_label, :use_markup, true)
            push!(hbox_b_m_4, b_m_4_label)
        # Dritter Bereich ("Spalte")
            b_m_4 = GtkButton("Keep as Module 4")
            set_gtk_property!(b_m_4, :margin_left, 10)
            set_gtk_property!(b_m_4, :margin_right, 10)
            push!(hbox_b_m_4, b_m_4)
        # Vierter Bereich ("Spalte")
            b_m_4_reset = GtkButton("Reset Module 4")
            set_gtk_property!(b_m_4_reset, :margin_left, 10)
            set_gtk_property!(b_m_4_reset, :margin_right, 10)
            set_gtk_property!(b_m_4_reset, :sensitive, false)
            push!(hbox_b_m_4, b_m_4_reset)

        function save_module_4(widget)
            set_gtk_property!(b_m_4, :sensitive, false)
            all_modules[4] = get_current_module()
            set_gtk_property!(b_m_4_reset, :sensitive, true)
            if get_gtk_property(b_m_1_reset, :sensitive, Bool) && get_gtk_property(b_m_2_reset, :sensitive, Bool) && get_gtk_property(b_m_3_reset, :sensitive, Bool)
                set_gtk_property!(b_save_song, :sensitive, true)
                set_gtk_property!(b_save_song, :has_tooltip, false)
            end
            set_gtk_property!(b_m_4_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"green\">Saved</span>")
        end
        save_module_4_s = signal_connect(save_module_4, b_m_4, :clicked)

        function reset_module_4(widget)
            set_gtk_property!(b_m_4_reset, :sensitive, false)
            all_modules[1] = Array{Float64}(undef, 0, 0)
            set_gtk_property!(b_m_4, :sensitive, true)
            set_gtk_property!(b_save_song, :sensitive, false)
            set_gtk_property!(b_save_song, :has_tooltip, true)
            set_gtk_property!(b_m_4_label, :label, "<span size=\"large\" weight=\"bold\" foreground=\"red\">Empty</span>")
        end
        reset_module_4_s = signal_connect(reset_module_4, b_m_4_reset, :clicked)

    # Achter Bereich ("Reihe")
        b_save_song = GtkButton("Save Song (all modules)")
        set_gtk_property!(b_save_song, :margin_left, 10)
        set_gtk_property!(b_save_song, :margin_right, 10)
        set_gtk_property!(b_save_song, :sensitive, false)
        set_gtk_property!(b_save_song, :tooltip_text, "Choose all modules first!")
        push!(vbox2, b_save_song)

        @guarded function save_song(widget)
            set_gtk_property!(main_win, :sensitive, false)
            set_gtk_property!(main_win, :accept_focus, false)
            motives = []
            for i = 1:4
                push!(motives, bitArr2notes(all_modules[i], 0.5))
            end
            notes = Notes()
            for i in motives[1]
                push!(notes, i)
            end
            notes = appendMotive(motives[1], 1, notes)
            notes = appendMotive(motives[2], 2, notes)
            notes = appendMotive(motives[1], 3, notes)
            notes = appendMotive(motives[3], 4, notes)
            notes = appendMotive(motives[4], 5, notes)
            notes = appendMotive(motives[2], 6, notes)
            notes = appendMotive(motives[1], 7, notes)
            notes = appendMotive(motives[4], 8, notes)
            notes = appendMotive(motives[1], 9, notes)

            file = MIDIFile()
            track = MIDITrack()
            addnotes!(track, notes)
            addtrackname!(track, "simple track")
            push!(file.tracks, track)
            writeMIDIFile(save_dialog_native("Save as...", GtkNullContainer(), ("*.mid",)), file)
            set_gtk_property!(main_win, :sensitive, true)
            set_gtk_property!(main_win, :accept_focus, true)
        end
        
        save_song_signal = signal_connect(save_song, b_save_song, :clicked)

function draw_pattern(values, canvas)
    @guarded draw(canvas) do widget
        ctx = getgc(canvas)
        h = height(canvas)
        w = width(canvas)

        # Clear Canvas
        set_source_rgb(ctx, 1.0, 1.0, 1.0)
        rectangle(ctx, 0, 0, w, h)
        fill(ctx)

        y_axe = 16
        x_axe = 21
        one_width = w/y_axe
        one_height = h/x_axe
        for i = 1:x_axe
            for i2 = 1:y_axe
                set_source_rgb(ctx, 1.0-values[i, i2], 1.0-values[i, i2], 1.0-values[i, i2])
                rectangle(ctx, (i2-1)*one_width, (i-1)*one_height, one_width, one_height)
                fill(ctx)
            end
        end
    end
end

function update_played_notes(widget)
    update_notes()
end

update_played_notes_signal = signal_connect(update_played_notes, sureness_slider, :value_changed)

function randomize_features(widget)
    signal_handler_block(slider_1, update_connect_1)
    signal_handler_block(slider_2, update_connect_2)
    signal_handler_block(slider_3, update_connect_3)
    signal_handler_block(slider_4, update_connect_4)
    signal_handler_block(slider_5, update_connect_5)
    set_gtk_property!(slider_1_adj, :value, rand())
    set_gtk_property!(slider_2_adj, :value, rand())
    set_gtk_property!(slider_3_adj, :value, rand())
    set_gtk_property!(slider_4_adj, :value, rand())
    set_gtk_property!(slider_5_adj, :value, rand())
    update_notes()
    signal_handler_unblock(slider_1, update_connect_1)
    signal_handler_unblock(slider_2, update_connect_2)
    signal_handler_unblock(slider_3, update_connect_3)
    signal_handler_unblock(slider_4, update_connect_4)
    signal_handler_unblock(slider_5, update_connect_5)
end
randomize_features_signal = signal_connect(randomize_features, b_randomize, "clicked")

function save_module(widget)
    #println(save_dialog_native("Wähle einen Speicherort!"))
    set_gtk_property!(main_win, :sensitive, false)
    set_gtk_property!(main_win, :accept_focus, false)
    motive = bitArr2notes(get_current_module(), 0.5)
    notes = Notes()
    for i in motive
        push!(notes, i)
    end
    file = MIDIFile()
    track = MIDITrack()
    addnotes!(track, notes)
    addtrackname!(track, "simple track")
    push!(file.tracks, track)
    writeMIDIFile(save_dialog_native("Save as...", GtkNullContainer(), ("*.mid",)), file)
    set_gtk_property!(main_win, :sensitive, true)
    set_gtk_property!(main_win, :accept_focus, true)
end
save_module_signal = signal_connect(save_module, b_save_m, "clicked")

update_notes()
println("App loaded.")
@info "!!!Please don't close this window; try closing the app first!!!"

playing_module = get_current_module()

showall(main_win)

@async begin
    cur_progress = sfMusic_getPlayingOffset(cursong).microseconds / 1000000
    while get_gtk_property(main_win, :visible, Bool)
        global curr_slider_changing
        #println(curr_slider_changing)
        if curr_slider_changing == false
            cur_progress = sfMusic_getPlayingOffset(cursong).microseconds / 1000000
            set_gtk_property!(playing_progress_adj, :value, cur_progress / 0.25)
            if sfMusic_getStatus(cursong) == sfStopped
                set_gtk_property!(b_pause, :sensitive, false)
                set_gtk_property!(b_play, :sensitive, true)
            end
        end
        sleep(0.1)
    end
end

while get_gtk_property(main_win, :visible, Bool)
    sleep(0.2)
end
#println(main_win)
println("Closing...")
sfMusic_destroy(cursong)

#=
#mode = :learn
mode = :generate

if mode == :learn
    trainingsdata = make_trainingsdata()
    @time network = learning(trainingsdata, eps)

    println()
    #make_song()
else
    compose(2)
    #notes2bitArr(make_test_notes_from_midi(0, "songs/test2.mid", 1))
end
=#
end # module

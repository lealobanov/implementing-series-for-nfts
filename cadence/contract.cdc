// The below is a series structure that lays out how a series is to be created

// Variable size dictionary of SeriesData structs
access(self) var seriesData: {UInt32: SeriesData}

// Variable size dictionary of Series resources
access(self) var series: @{UInt32: Series}

// Structure for SeriesData
access(all)
struct SeriesData {

    // Unique ID for the Series
    access(all)
    let seriesId: UInt32

    // Dictionary of metadata key-value pairs
    access(self)
    var metadata: {String: String}

    init(
        seriesId: UInt32,
        metadata: {String: String}
    ) {
        self.seriesId = seriesId
        self.metadata = metadata

        emit SeriesCreated(seriesId: self.seriesId)
    }

    // Retrieves metadata of the series
    access(all)
    view fun getMetadata(): {String: String} {
        return self.metadata
    }
}

// Resource that allows an admin to manage and mint new NFTs for a series
access(all)
resource Series {

    // Unique ID for the Series
    access(all)
    let seriesId: UInt32

    // Array of NFTSets that belong to this Series
    access(self)
    var setIds: [UInt32]

    // Series sealed state
    access(all)
    var seriesSealedState: Bool

    // Set sealed state
    access(self)
    var setSealedState: {UInt32: Bool}

    // Current number of editions minted per Set
    access(self)
    var numberEditionsMintedPerSet: {UInt32: UInt32}

    init(
        seriesId: UInt32,
        metadata: {String: String}
    ) {
        self.seriesId = seriesId
        self.seriesSealedState = false
        self.numberEditionsMintedPerSet = {}
        self.setIds = []
        self.setSealedState = {}

        SetAndSeries.seriesData[seriesId] = SeriesData(
            seriesId: seriesId,
            metadata: metadata
        )
    }

    // Adds a new NFTSet to this series
    access(all)
    fun addNftSet(
        setId: UInt32,
        maxEditions: UInt32,
        ipfsMetadataHashes: {UInt32: String},
        metadata: {String: String}
    ) {
        pre {
            self.setIds.contains(setId) == false: "The Set has already been added to the Series."
        }

        // Create the new Set struct
        let newNFTSet = NFTSetData(
            setId: setId,
            seriesId: self.seriesId,
            maxEditions: maxEditions,
            ipfsMetadataHashes: ipfsMetadataHashes,
            metadata: metadata
        )

        // Add the NFTSet to the array of Sets
        self.setIds.append(setId)

        // Initialize the NFT edition count to zero
        self.numberEditionsMintedPerSet[setId] = 0

        // Store it in the sets mapping field
        SetAndSeries.setData[setId] = newNFTSet

        emit SetCreated(seriesId: self.seriesId, setId: setId)
    }

    // Mints a new NFT with a new ID and deposits it in the recipient's collection
    access(all)
    fun mintSetAndSeriesNFT(
        recipient: &{NonFungibleToken.CollectionPublic},
        tokenId: UInt64,
        setId: UInt32
    ) {
        pre {
            self.numberEditionsMintedPerSet[setId] != nil: "The Set does not exist."
            self.numberEditionsMintedPerSet[setId]! < SetAndSeries.getSetMaxEditions(setId: setId)!:
                "Set has reached maximum NFT edition capacity."
        }

        // Gets the number of editions that have been minted so far in this set
        let editionNum: UInt32 = self.numberEditionsMintedPerSet[setId]! + (1 as UInt32)

        // Deposit it in the recipient's account using their reference
        recipient.deposit(token: <-create SetAndSeries.NFT(
            tokenId: tokenId,
            setId: setId,
            editionNum: editionNum
        ))

        // Increment the count of global NFTs
        SetAndSeries.totalSupply = SetAndSeries.totalSupply + (1 as UInt64)

        // Update the count of Editions minted in the set
        self.numberEditionsMintedPerSet[setId] = editionNum
    }
}

// Admin is a special authorization resource that allows the owner to perform important NFT functions
access(all)
resource Admin {

    // Adds a new series
    access(all)
    fun addSeries(
        seriesId: UInt32,
        metadata: {String: String}
    ) {
        pre {
            SetAndSeries.series[seriesId] == nil:
                "Cannot add Series: The Series already exists"
        }

        // Create the new Series
        let newSeries <- create Series(
            seriesId: seriesId,
            metadata: metadata
        )

        // Add the new Series resource to the Series dictionary in the contract
        SetAndSeries.series[seriesId] <-! newSeries
    }

    // Borrows a reference to an existing series
    access(all)
    fun borrowSeries(seriesId: UInt32): &Series {
        pre {
            SetAndSeries.series[seriesId] != nil:
                "Cannot borrow Series: The Series does not exist"
        }

        // Get a reference to the Series and return it
        return &SetAndSeries.series[seriesId] as &Series
    }

    // Creates a new Admin resource
    access(all)
    fun createNewAdmin(): @Admin {
        return <-create Admin()
    }
}

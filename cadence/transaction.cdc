import SetAndSeries from 0x01

transaction {

    let adminCheck: auth(AdminEntitlement) &SetAndSeries.Admin

    prepare(acct: auth(Storage, Capabilities) &Account) {
        // Borrow the admin reference with entitlement-based access
        self.adminCheck = acct.capabilities.storage.borrow<&SetAndSeries.Admin>(
            from: SetAndSeries.AdminStoragePath
        ) ?? panic("Could not borrow admin reference")
    }

    execute {
        // Add a new series using the borrowed admin reference
        self.adminCheck.addSeries(seriesId: 1, metadata: {"Series": "1"})
        log("Series added")
    }
}

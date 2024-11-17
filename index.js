// Pass the repo name
const recipe = "implementing-series-for-nfts";

//Generate paths of each code file to render
const contractPath = `${recipe}/cadence/contract.cdc`;
const transactionPath = `${recipe}/cadence/transaction.cdc`;

//Generate paths of each explanation file to render
const smartContractExplanationPath = `${recipe}/explanations/contract.txt`;
const transactionExplanationPath = `${recipe}/explanations/transaction.txt`;

export const implementingSeriesForNFTs = {
  slug: recipe,
  title: "Implementing Series for NFTs",
  createdAt: new Date(2022, 9, 14),
  author: "Flow Blockchain",
  playgroundLink:
    "https://play.onflow.org/a7d190b6-e0f1-4acc-b34c-f37b39fbab33?type=tx&id=c252ea40-397c-43b0-acfb-c504a7268175&storage=none",
  excerpt:
    "This cadence code will help you being to understand how to implement series and sets into your NFT project.",
  smartContractCode: contractPath,
  smartContractExplanation: smartContractExplanationPath,
  transactionCode: transactionPath,
  transactionExplanation: transactionExplanationPath,
  filters: {
    difficulty: "intermediate",
  },
};

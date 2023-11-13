// SPDX-License-Identifier: UNLICENSED
// create the smart contract
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        uint256 goal;
        uint256 deadline;
        uint256 raised;
        bool closed;
        string title;
        string description;
        string image; // url
        address[] contributors;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount = 0;

    function createCampaign(
        address _owner,
        uint256 _goal,
        uint256 _deadline,
        string memory _title,
        string memory _description,
        string memory _image
    ) public returns (uint256) {
        require(_goal > 0, "Goal must be greater than 0");
        require(_deadline < block.timestamp, "Deadline must be in the future");

        campaigns[campaignCount] = Campaign(
            _owner,
            _goal,
            _deadline,
            0,
            false,
            _title,
            _description,
            _image,
            new address[](0),
            new uint256[](0)
        );
        campaignCount++;

        return campaignCount - 1;
    }

    function contribute(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.closed, "Campaign is closed");
        require(
            campaign.deadline > block.timestamp,
            "Campaign deadline has passed"
        );
        require(msg.value > 0, "Contribution must be greater than 0");

        uint256 newRaised = msg.value;
        campaign.contributors.push(msg.sender);
        campaign.donations.push(newRaised);

        (bool success, ) = payable(campaign.owner).call{value: newRaised}("");

        if (!success) {
            revert("Transfer failed");
        } else {
            campaign.raised += newRaised;
        }

        // if (campaign.raised >= campaign.goal) {
        //     campaign.closed = true;
        // }
    }

    function getContributors(
        uint256 _campaignId
    ) public view returns (address[] memory, uint256[] memory) {
        return (
            campaigns[_campaignId].contributors,
            campaigns[_campaignId].donations
        );
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        // create a new array allCampaigns with the same length as campaignCount
        Campaign[] memory allCampaigns = new Campaign[](campaignCount);

        for (uint256 i = 0; i < campaignCount; i++) {
            allCampaigns[i] = campaigns[i];
        }

        return allCampaigns;
    }
}

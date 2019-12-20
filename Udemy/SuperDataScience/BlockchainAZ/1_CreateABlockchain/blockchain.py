"""
    Author:         CaptCorpMURICA
    Project:        BlockchainAZ
    File:           blockchain.py
    Creation Date:  1/31/2019, 7:51 PM
    Description:    Create a general blockchain for Module 1 of Blockchain A-Z
"""

# To be installed:
#   Flask
#   Postman HTTP Client

# Importing the libraries
import datetime
import hashlib
import json
from flask import Flask, jsonify


##################################
# Part 1 - Building a Blockchain #
##################################

class Blockchain:

    def __init__(self):
        self.chain = []  # Initialize the chain as an open list
        # Create the genesis block
        # Call a function that creates the first block with a default previous hash of 0
        self.create_block(proof=1, previous_hash='0')

    # Define the create_block() function
    #   Index - Length of the chain + 1
    #   Timestamp - UTC time of the block
    #   Proof - Solution of the Proof of Work function calculated when mining the block
    #   Previous Hash - Hash value of the previous block in the chain
    def create_block(self, proof, previous_hash):
        # Initialize the block as a dictionary
        block = {'index': len(self.chain) + 1,
                 'timestamp': str(datetime.datetime.utcnow()),
                 'proof': proof,
                 'previous_hash': previous_hash}
        # Append the block to the chain
        self.chain.append(block)
        # Return the block from the function
        return block

    # Create a function to get the previous block (last item in the chain list)
    def get_previous_block(self):
        return self.chain[-1]

    # Create the Proof of Work function
    # Should be hard to find, but easy to verify
    def proof_of_work(self, previous_proof):
        new_proof = 1
        check_proof = False
        while check_proof is False:
            # The more leading zeros, the harder the problem
            # Operation cannot be symmetrical
            hash_operation = hashlib.sha256(str(new_proof ** 2 - previous_proof ** 2).encode()).hexdigest()
            # Check if first four characters are four zeroes in the hash_operation variable
            if hash_operation[0:4] == '0000':
                check_proof = True
            else:
                new_proof += 1
        # End function by returning the new_proof variable
        return new_proof

    # Create a function to encode the block using SHA 256 encryption
    def hash(self, block):
        encoded_block = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(encoded_block).hexdigest()

    # Create a function to check if:
    #   Every block in the chain has a correct proof of work
    #   The previous block of the chain has a hash that matches the previous_hash of the subsequent block
    def is_chain_valid(self, chain):
        previous_block = chain[0]
        block_index = 1
        while block_index < len(chain):
            block = chain[block_index]

            # Check that the previous hash is equal to the hash of the previous block
            if block['previous_hash'] != self.hash(previous_block):
                return False

            # Check if the proof is valid
            previous_proof = previous_block['proof']
            proof = block['proof']
            hash_operation = hashlib.sha256(str(proof ** 2 - previous_proof ** 2).encode()).hexdigest()
            if hash_operation[0:4] != '0000':
                return False

            # Store the current block as the previous_block variable to continue the loop
            # Iterate the block_index variable to continue the loop
            previous_block = block
            block_index += 1

        return True


##################################
# Part 2 - Mining the Blockchain #
##################################

# Creating a Web App
app = Flask(__name__)

# Creating a Blockchain
blockchain = Blockchain()


# Mining a new block
@app.route('/mine_block', methods=['GET'])
def mine_block():
    # Create variables needed to create a new block in the chain
    previous_block = blockchain.get_previous_block()
    previous_proof = previous_block['proof']
    proof = blockchain.proof_of_work(previous_proof)
    previous_hash = blockchain.hash(previous_block)

    # Use the declared variables to create a new block based on the previous block
    block = blockchain.create_block(proof, previous_hash)

    # Contains information in the block and a message for the miner
    response = {'message': 'Congratulations, you just mined a block!',
                'index': block['index'],
                'timestamp': block['timestamp'],
                'proof': block['proof'],
                'previous_hash': block['previous_hash']}

    # Return the output of the function
    # Use the 200 HTTP status code (OK) to indicate the function completed successfully
    return jsonify(response), 200


# Getting the full Blockchain
@app.route('/get_chain', methods=['GET'])
def get_chain():
    response = {'chain': blockchain.chain,
                'length': len(blockchain.chain)}
    return jsonify(response), 200


# Running the app
app.run(host='0.0.0.0', port=5000)

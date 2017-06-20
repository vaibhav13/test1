# encoding: UTF-8
require_relative '../spec_helper'

describe MockServer::ProxyClient do

  let(:client) { MockServer::ProxyClient.new('localhost', 8080) }
  let(:retrieved_request) { FIXTURES.read('retrieved_request.json') }
  let(:retrieved_request_json) { retrieved_request.to_json }
  let(:search_request_json) { FIXTURES.read('search_request.json').to_json }

  before do
    # To suppress logging output to standard output, write to a temporary file
    client.logger = LoggingFactory::DEFAULT_FACTORY.log('test', output: 'tmp.log', truncate: true)

    # Stub requests
    stub_request(:put, /.+\/retrieve/).with(body: search_request_json).to_return(
      body:   "[#{retrieved_request_json}, #{retrieved_request_json}]",
      status: 200
    )
    stub_request(:put, /.+\/dumpToLog$/).to_return(status: 202).once
    stub_request(:put, /.+\/dumpToLog\?type=java$/).to_return(status: 202).once
  end

  it 'verifies requests correctly' do
    response = client.verify(request(:POST, '/login'), exactly(2))
    response = response.map { |mock| to_camelized_hash(mock.to_hash) }
    expect(response).to eq([retrieved_request, retrieved_request])
  end

  it 'raises an error when verification fails' do
    expect { client.verify(request(:POST, '/login')) }.to raise_error(RuntimeError, 'Expected request to be present: [1] (exactly). But found: [2]')
  end

  it 'dumps to logs correctly do' do
    expect(client.dump_log.code).to eq(202)
    expect(client.dump_log({}, true).code).to eq(202)
  end
end

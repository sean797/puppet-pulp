require 'spec_helper_acceptance'

describe 'certs with default params' do
  context 'with default params' do
    let(:pp) do
      <<-EOS
      class { '::pulp::repo::katello':} ->
      class { '::pulp':} 
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe package('pulp-server') do
      it { is_expected.to be_installed }
    end
    describe package('pulp-selinux') do
      it { is_expected.to be_installed }
    end
    describe package('python-pulp-streamer') do
      it { is_expected.to be_installed }
    end

    status_url = "https://$(hostname)/pulp/api/v2/status/ --cacert /etc/pki/katello/certs/katello-default-ca.crt"
    describe "API" do
      it 'should return the correct status' do
        data = JSON.load curl_on(default, status_url).stdout
        expect(data['database_connection']['connected']).to be true
        expect(data['messaging_connection']['connected']).to be true
      end
    end

#    describe file("/etc/pki/katello-certs-tools/certs/katello-default-ca.crt") do
#      it { should be_file }
#      it { expect(shell("/usr/bin/openssl x509 -in /etc/pki/katello-certs-tools/certs/katello-default-ca.crt -noout -subject").stdout).to match(fact('fqdn')) }
#    end
#
#    describe file("/etc/pki/katello-certs-tools/certs/katello-server-ca.crt") do
#      it { should be_file }
#      it { expect(shell("/usr/bin/openssl x509 -in /etc/pki/katello-certs-tools/certs/katello-server-ca.crt -noout -subject").stdout).to match(fact('fqdn')) }
#    end
  end
end

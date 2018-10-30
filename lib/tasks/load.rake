namespace :load do
  desc 'Generates jmeter test plan'
  task :jmeter_plan, [:url, :email, :password, :count] do |t, args|
    require 'ruby-jmeter'
    generate_report *extract_options_from(args)
  end

  def extract_options_from(args)
    defaults = {
      url: 'http://localhost:3000',
      email: 'test@test.com',
      password: 'password',
      count: 10
    }

    options = defaults.merge(args)
    [options[:url], options[:email], options[:password], options[:count].to_i]
  end

  def generate_report(url, email, password, count)
    uri = URI(url)
    domain, port = uri.host, uri.port
    test do
      threads count: count do
        defaults domain: domain, port: port
        cookies policy: 'rfc2109', clear_each_iteration: true

        transaction 'dashboard_pages' do
          visit name: '/', url: '/' do
            extract name: 'csrf-token', xpath: "//meta[@name='csrf-token']/@content", tolerant: true
            extract name: 'csrf-param', xpath: "//meta[@name='csrf-param']/@content", tolerant: true
          end

          http_header_manager name: 'X-CSRF-Token', value: '${csrf-token}'

          submit name: '/users/sign_in', url: '/users/sign_in',
            fill_in: {
            '${csrf-param}' => '${csrf-token}',
            'user[email]' => email,
            'user[password]' => password,
          }

          visit name: '/dashboard', url: '/dashboard' do
            extract name: 'menu-urls',
              xpath: "//div[contains(@class, 'article_body')]//ul//a/@href", tolerant: true
          end

          visit name: 'Today', url: '${menu-urls_1}'
          visit name: 'Assigned', url: '${menu-urls_3}'
          visit name: 'Overview', url: '${menu-urls_5}'
        end

        view_results_in_table
        view_results_tree
        graph_results
        aggregate_graph
      end
    end.jmx
  end
end

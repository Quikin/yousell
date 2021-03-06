# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Yousell::Application

# http://blog.phusion.nl/2013/01/22/phusion-passenger-4-technology-preview-out-of-band-work/

if defined?(PhusionPassenger) && !Rails.env.development?
  require 'phusion_passenger/rack/out_of_band_gc'
  # Trigger out-of-band GC every 3 requests.
  use PhusionPassenger::Rack::OutOfBandGc, 3
  ## Optional: disable normal GC triggers and only GC outside
  ## request cycles. Not recommended though, see section
  ## "What Ruby can do to improve out-of-band garbage collection"
  # GC.disable
end


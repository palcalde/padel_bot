module Canal
  class Payload
    def self.get_payload_with_payment_data(data)
      p "get_payload_with_payment_data before #{data}"
      self.get_sample_payload.tap do |h|
        h['price'] = data['model']['Price']
        h['idType'] = data['model']['IdType']
        payment_method = data['paymentMethods'].find {|p| p['name'].include?('Bono Monedero')}
        h['idPaymentmethod'] = payment_method['id']
        h['idResource'] = data['model']['IdResource']
        h['idSearch'] = data['model']['IdSearch']
      end
    end

    def self.get_sample_payload
      {
        "portal": nil,
        "club": nil,
        "idCenter": 272,
        "lat": "40.403688100000004",
        "lon": "-3.711462",
        "radius": "20",
        "date": "2016-10-10T00:00:00",
        "time": "09:00",
        "duration": 90,
        "price": nil,
        "period": nil,
        "idType": nil,
        "typeName": nil,
        "idPaymentmethod": nil,
        "idResource": nil,
        "pending": nil,
        "isMyLocation": true,
        "idSearch": 1529,
        "searchText": "Cerca de mí",
        "isFilterIndoor": true,
        "isFilterOutdoor": nil,
        "isFilterCubierta": true,
        "isFilterMuro": true,
        "isFilterCristal": true,
        "isFilterPanoramica": true,
        "isFilterDobles": true,
        "isFilterIndividual": false,
        "createDate": "2016-10-04T21:17:18.689Z",
        "localLatitude": nil,
        "localLongitude": nil,
        "isFilterExterior": true
      }.clone
    end
  end
end

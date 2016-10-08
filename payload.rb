module Canal
  class Payload
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

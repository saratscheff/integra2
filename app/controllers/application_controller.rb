class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include HmacHelper # Para utilizar la función de hashing

  # Las variables globales se asignan según el ambiente en el que se esté desarrollando
  if Rails.env.production?
    $groupid = "572aac69bdb6d403005fb043"
    $bancoid = "572aac69bdb6d403005fb04f"
    $recepcionid = "572aad41bdb6d403005fb0ba"
    $despachoid = "572aad41bdb6d403005fb0bb"
  else
    $groupid = "571262b8a980ba030058ab50"
    $bancoid = "571262c3a980ba030058ab5c"
    $recepcionid = "571262aaa980ba030058a14e"
    $despachoid = "571262aaa980ba030058a14f"
  end
  ##### Método para obtener el almacenID en vivo
  #  parsed_json = lista_de_almacenes() # Función definida en ApplicationController
  #  almId = nil # Necesario declararlo fuera del loop
  #  parsed_json.each do |almacen|
  #    almId = almacen["_id"] if almacen["recepcion"] # TODO: y si tenemos más de una bodega de recepcion??
  #  end
  #  return almId
  #####

  private

  def transform_oc(oc)
    oc.delete("__v")
    puts oc.to_s
    oc.delete("fechaDespachos")
    puts oc.to_s
    oc.delete("rechazo")
    oc.delete("precioUnitario")
    oc["idoc"] = oc.delete("_id")
    oc["fechaRecepcion"] = Time.new(oc.delete("created_at")).to_s
    oc["fechaEntrega"] = Time.new(oc.delete("fechaEntrega")).to_s
  end

  #Esta función es para ejecutar código en background, paralelo al http request
  def background(&block)
    puts "-------------Iniciando Nuevo THREAD------------------"
    # Genero un nuevo Thread (Proceso aparte del original e independiente)
    Thread.new do
      # Con yield le digo que ejecute el código del bloque aquí dentro
      yield
      # Luego cierro la conexión a la database que un Thread nuevo siempre abre
      ActiveRecord::Base.connection.close
      puts "-------------THREAD Finalizado------------------"
    end
  end

  # --------------------------------------------------------------------------
  # ------------------------------Links---------------------------------------
  # --------------------------------------------------------------------------

  def getLinkServidorCurso()
    if Rails.env.production?
      return "http://moto.ing.puc.cl"
    else
      return "http://mare.ing.puc.cl/"
    end
  end

  def getLinkServidorGrupo(numeroGrupo)
    # Habilitar esta línea para hacer pruebas locales
    # return "http://localhost:3000/"
    # Habilitar esta línea para deployment
    return "http://integra" + numeroGrupo + ".ing.puc.cl/"
  end

  # --------------------------------------------------------------------------
  # ------------------------------IDs-----------------------------------------
  # --------------------------------------------------------------------------

  #TODO: Corregir ids
  def getLinkGrupo(id) #Los IDS están malos, reemplazarlos por los correctos cuando los sepamos
    grupo = get_grupo_by_id(id)
    return nil if grupo == nil
    url = getLinkServidorGrupo(grupo)
    return url
  end

  def get_grupo_by_id(id)
    if Rails.env.production?
              # ID del grupo => Número del Grupo
      dic = {'572aac69bdb6d403005fb042'=>'1',
            '572aac69bdb6d403005fb043'=>'2',
            '572aac69bdb6d403005fb044'=>'3',
            '572aac69bdb6d403005fb045'=>'4',
            '572aac69bdb6d403005fb046'=>'5',
            '572aac69bdb6d403005fb047'=>'6',
            '572aac69bdb6d403005fb048'=>'7',
            '572aac69bdb6d403005fb049'=>'8',
            '572aac69bdb6d403005fb04a'=>'9',
            '572aac69bdb6d403005fb04b'=>'10',
            '572aac69bdb6d403005fb04c'=>'11',
            '572aac69bdb6d403005fb04d'=>'12'}
    else
              # ID del grupo => Número del Grupo
      dic = {'571262b8a980ba030058ab4f'=>'1',
            '571262b8a980ba030058ab50'=>'2',
            '571262b8a980ba030058ab51'=>'3',
            '571262b8a980ba030058ab52'=>'4',
            '571262b8a980ba030058ab53'=>'5',
            '571262b8a980ba030058ab54'=>'6',
            '571262b8a980ba030058ab55'=>'7',
            '571262b8a980ba030058ab56'=>'8',
            '571262b8a980ba030058ab57'=>'9',
            '571262b8a980ba030058ab58'=>'10',
            '571262b8a980ba030058ab59'=>'11',
            '571262b8a980ba030058ab5a'=>'12'}
    end
    return dic[id]
  end

  def get_id_by_group(group)
    if Rails.env.production?
              # ID del grupo => Número del Grupo
      dic = {'572aac69bdb6d403005fb042'=>'1',
            '572aac69bdb6d403005fb043'=>'2',
            '572aac69bdb6d403005fb044'=>'3',
            '572aac69bdb6d403005fb045'=>'4',
            '572aac69bdb6d403005fb046'=>'5',
            '572aac69bdb6d403005fb047'=>'6',
            '572aac69bdb6d403005fb048'=>'7',
            '572aac69bdb6d403005fb049'=>'8',
            '572aac69bdb6d403005fb04a'=>'9',
            '572aac69bdb6d403005fb04b'=>'10',
            '572aac69bdb6d403005fb04c'=>'11',
            '572aac69bdb6d403005fb04d'=>'12'}
    else
              # ID del grupo => Número del Grupo
      dic = {'571262b8a980ba030058ab4f'=>'1',
            '571262b8a980ba030058ab50'=>'2',
            '571262b8a980ba030058ab51'=>'3',
            '571262b8a980ba030058ab52'=>'4',
            '571262b8a980ba030058ab53'=>'5',
            '571262b8a980ba030058ab54'=>'6',
            '571262b8a980ba030058ab55'=>'7',
            '571262b8a980ba030058ab56'=>'8',
            '571262b8a980ba030058ab57'=>'9',
            '571262b8a980ba030058ab58'=>'10',
            '571262b8a980ba030058ab59'=>'11',
            '571262b8a980ba030058ab5a'=>'12'}
    end
    return dic.key(group)
  end

  #TODO: Corregir ids y concatenación
  def getLinkGrupoSegunCuenta(idCuenta)
    if Rails.env.production?
            # Cuenta del Grupo => Número del Grupo
      dic = {'572aac69bdb6d403005fb04e'=>'1',
            '572aac69bdb6d403005fb04f'=>'2',
            '572aac69bdb6d403005fb050'=>'3',
            '572aac69bdb6d403005fb051'=>'4',
            '572aac69bdb6d403005fb052'=>'5',
            '572aac69bdb6d403005fb053'=>'6',
            '572aac69bdb6d403005fb054'=>'7',
            '572aac69bdb6d403005fb056'=>'8',
            '572aac69bdb6d403005fb057'=>'9',
            '572aac69bdb6d403005fb058'=>'10',
            '572aac69bdb6d403005fb059'=>'11',
            '572aac69bdb6d403005fb05a'=>'12'}
    else
            # Cuenta del Grupo => Número del Grupo
      dic = {'571262c3a980ba030058ab5b'=>'1',
            '571262c3a980ba030058ab5c'=>'2',
            '571262c3a980ba030058ab5d'=>'3',
            '571262c3a980ba030058ab5f'=>'4',
            '571262c3a980ba030058ab61'=>'5',
            '571262c3a980ba030058ab62'=>'6',
            '571262c3a980ba030058ab60'=>'7',
            '571262c3a980ba030058ab5e'=>'8',
            '571262c3a980ba030068ab66'=>'9',
            '571262c3a980ba030058ab63'=>'10',
            '571262c3a980ba030058ab64'=>'11',
            '571262c3a980ba030068ab65'=>'12'}
    end
    url = getLinkServidorGrupo(dic[idCuenta])
    return url
  end

  #TODO: Corregir ids
  def getIdBanco(grupo)
    if Rails.env.production?
            # Número del Grupo => Cuenta del Grupo
      dic = {'1'=>'572aac69bdb6d403005fb04e',
            '2'=>'572aac69bdb6d403005fb04f',
            '3'=>'572aac69bdb6d403005fb050',
            '4'=>'572aac69bdb6d403005fb051',
            '5'=>'572aac69bdb6d403005fb052',
            '6'=>'572aac69bdb6d403005fb053',
            '7'=>'572aac69bdb6d403005fb054',
            '8'=>'572aac69bdb6d403005fb056',
            '9'=>'572aac69bdb6d403005fb057',
            '10'=>'572aac69bdb6d403005fb058',
            '11'=>'572aac69bdb6d403005fb059',
            '12'=>'572aac69bdb6d403005fb05a'}
    else
            # Número del Grupo => Cuenta del Grupo
      dic = {'1'=>'571262c3a980ba030058ab5b',
            '2'=>'571262c3a980ba030058ab5c',
            '3'=>'571262c3a980ba030058ab5d',
            '4'=>'571262c3a980ba030058ab5f',
            '5'=>'571262c3a980ba030058ab61',
            '6'=>'571262c3a980ba030058ab62',
            '7'=>'571262c3a980ba030058ab60',
            '8'=>'571262c3a980ba030058ab5e',
            '9'=>'571262c3a980ba030068ab66',
            '10'=>'571262c3a980ba030058ab63',
            '11'=>'571262c3a980ba030058ab64',
            '12'=>'571262c3a980ba030068ab65'}
    end
    return dic[grupo]
   end

   #TODO: Corregir ids
   def get_almacen_id(grupo)
     if Rails.env.production?
             # Número del Grupo => Almacen De Recepcion del Grupo
       dic = {'1'=>'572aad41bdb6d403005fb066',
              '2'=>'572aad41bdb6d403005fb0ba',
              '3'=>'572aad41bdb6d403005fb1bf',
              '4'=>'572aad41bdb6d403005fb208',
              '5'=>'572aad41bdb6d403005fb278',
              '6'=>'572aad41bdb6d403005fb2d8',
              '7'=>'572aad41bdb6d403005fb3b9',
              '8'=>'572aad41bdb6d403005fb416',
              '9'=>'572aad41bdb6d403005fb4b8',
              '10'=>'572aad41bdb6d403005fb542',
              '11'=>'572aad41bdb6d403005fb5b9',
              '12'=>'572aad42bdb6d403005fb69f'}
      else
              # Número del Grupo => Almacen De Recepcion del Grupo
        dic = {'1'=>'571262aaa980ba030058a147',
               '2'=>'571262aaa980ba030058a14e',
               '3'=>'571262aaa980ba030058a1f1',
               '4'=>'571262aaa980ba030058a240',
               '5'=>'571262aaa980ba030058a244',
               '6'=> false,
               '7'=> false,
               '8'=>'571262aaa980ba030058a31e',
               '9'=>'571262aaa980ba030058a3b0',
               '10'=>'571262aaa980ba030058a40c',
               '11'=>'571262aaa980ba030058a488',
               '12'=>'571262aba980ba030058a5c6'}
     end
     return dic[grupo]
    end

  #TODO: Corregir ids
  def getIdBancoSegunIdGrupo(id)
    if Rails.env.production?
                      # ID del Grupo => Cuenta del Grupo
      dic = {'572aac69bdb6d403005fb042'=>'572aac69bdb6d403005fb04e',
            '572aac69bdb6d403005fb043'=>'572aac69bdb6d403005fb04f',
            '572aac69bdb6d403005fb044'=>'572aac69bdb6d403005fb050',
            '572aac69bdb6d403005fb045'=>'572aac69bdb6d403005fb051',
            '572aac69bdb6d403005fb046'=>'572aac69bdb6d403005fb052',
            '572aac69bdb6d403005fb047'=>'572aac69bdb6d403005fb053',
            '572aac69bdb6d403005fb048'=>'572aac69bdb6d403005fb054',
            '572aac69bdb6d403005fb049'=>'572aac69bdb6d403005fb056',
            '572aac69bdb6d403005fb04a'=>'572aac69bdb6d403005fb057',
            '572aac69bdb6d403005fb04b'=>'572aac69bdb6d403005fb058',
            '572aac69bdb6d403005fb04c'=>'572aac69bdb6d403005fb059',
            '572aac69bdb6d403005fb04d'=>'572aac69bdb6d403005fb05a'}
    else
                      # ID del Grupo => Cuenta del Grupo
      dic = {'571262b8a980ba030058ab4f'=>'571262c3a980ba030058ab5b',
            '571262b8a980ba030058ab50'=>'571262c3a980ba030058ab5c',
            '571262b8a980ba030058ab51'=>'571262c3a980ba030058ab5d',
            '571262b8a980ba030058ab52'=>'571262c3a980ba030058ab5f',
            '571262b8a980ba030058ab53'=>'571262c3a980ba030058ab61',
            '571262b8a980ba030058ab54'=>'571262c3a980ba030058ab62',
            '571262b8a980ba030058ab55'=>'571262c3a980ba030058ab60',
            '571262b8a980ba030058ab56'=>'571262c3a980ba030058ab5e',
            '571262b8a980ba030058ab57'=>'571262c3a980ba030058ab66',
            '571262b8a980ba030058ab58'=>'571262c3a980ba030058ab63',
            '571262b8a980ba030058ab59'=>'571262c3a980ba030058ab64',
            '571262b8a980ba030058ab5a'=>'571262c3a980ba030068ab65'}
    end
    url = getLinkServidorGrupo(dic[id])
    return url
  end

  # ----------------------------------------------------------------------------
  # -----------------------------------OCs--------------------------------------
  # ----------------------------------------------------------------------------

  def obtener_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo OC--------------"
      url = getLinkServidorCurso + "oc/"
      result = HTTParty.get(url+"obtener/"+idoc.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
              })
      puts "(Obtener_OC)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error4: se retornó más de una OC para el mismo id" and return
      elsif json.count() == 0
        raise "Error: No existe la OC pedida" and return
      end
      puts "--------OC Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1012"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def transform_oc(oc)
    oc.delete("__v")
    oc.delete("fechaDespachos")
    oc.delete("precioUnitario")
    oc.delete("updated_at") if oc["updated_at"]
    oc.delete("notas") if oc["notas"]
    oc["idoc"] = oc.delete("_id")
    created_at = oc.delete("created_at")
    fechaEntrega = oc.delete("fechaEntrega")
    #TODO: restar 3 horas para quedar en GMT-3 o informar diferencia en /ocs
    oc["fechaRecepcion"] = created_at.to_s
    oc["fechaEntrega"] = fechaEntrega.to_s
    return oc
  end

  #-----------------------------------------------------------------------------
  # -------------------------------Facturas-------------------------------------
  # ----------------------------------------------------------------------------

  def generar_factura(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Generando Factura--------------"
      url = "http://mare.ing.puc.cl/facturas/"
      result = HTTParty.put(url,
              body: {
                oc: idoc
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Generar_Factura)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      # FORMATO FACTURA: {"__v"=>0, "created_at"=>"2016-05-02T14:57:30.324Z", "updated_at"=>"2016-05-02T14:57:30.324Z", "cliente"=>"571262b8a980ba030058ab50", "proveedor"=>"571262b8a980ba030058ab50", "bruto"=>6033, "iva"=>1147, "total"=>7180, "oc"=>"57276aaec1ff9b0300017d1b", "_id"=>"57276adac1ff9b0300017d1c", "estado"=>"pendiente"}
      localOc = Oc.find_by idoc: idoc
      localOc.idfactura = json["_id"]
      localOc.save!
      puts "--------Factura Generada--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def obtener_factura(idfactura)
    require 'httparty'
    puts "--------Obteniendo Factura--------------"
    url = getLinkServidorCurso + "facturas/"
    result = HTTParty.get(url+idfactura.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Obtener_Factura)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una factura para el mismo id"
    end
    puts "--------Factura Obtenida--------------"
    return json[0]
  end

  def anular_idoc(idoc)
    puts "--------Anulando idOC--------------"+idoc.to_s
    localOc = Oc.find_by idoc: idoc
    localOc["estado"] = "anulada por rechazo."
    localOc.save!
    url = getLinkServidorCurso + "oc/"
    result = HTTParty.delete(url + 'anular/' + idoc.to_s,
            body: {
              anulacion: "OC Rechazada por contraparte"
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    puts "(Anular_idOC)Respuesta de la contraparte: " + json.to_s
    puts "--------idOC Anulada--------------"
    return json
  end
  def anular_oc(oc)
    puts "--------Anulando OC--------------"+oc.to_s
    idOc = oc['_id']
    idOc = oc['idoc'] if (idOc == nil) # En caso de que oc no haya sido transformada todavía
    localOc = Oc.find_by idoc: idOc
    localOc["estado"] = "anulada por rechazo.."
    localOc.save!
    url = getLinkServidorCurso + "oc/"
    result = HTTParty.delete(url + 'anular/' + idOc.to_s,
            body: {
              anulacion: "OC Rechazada por contraparte"
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    puts "(Anular_OC)Respuesta de la contraparte: " + json.to_s
    puts "--------OC Anulada--------------"
    return json
  end
  #-----------------------------------------------------------------------------
  # ------------------------------Transacción-----------------------------------
  # ----------------------------------------------------------------------------

  def obtener_transaccion(idtrx)
    require 'httparty'
    puts "--------Obteniendo Transacción--------------"
    url = getLinkServidorCurso + "banco/"
    result = HTTParty.get(url++'trx/' + idtrx.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Obtener_Trx)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una transacción para el mismo id"
    end
    puts "--------Transacción Obtenida--------------"
    return json[0]
  end


  def transferir(cuentaOrigen, cuentoDestino, montoTransferencia)

    begin
      puts "--------Realizando Transacción--------------"
      url = getLinkServidorCurso + "banco/trx/"
      result = HTTParty.put(url,
              body: {
                monto: montoTransferencia.to_i,
                origen: cuentaOrigen,
                destino: cuentoDestino,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Transferir)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Transacción Realizada--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1001: " + ex.message
      render json: {"error": ex.message}, status: 503 and return
    end

  end




  # ----------------------------------------------------------------------------
  # ------------------------------Almacen---------------------------------------
  # ----------------------------------------------------------------------------

  def consultar_stock(sku)
    parsed_json = lista_de_almacenes()

    contador=0
    parsed_json.each do |almacen|
      contador += stock_de_almacen(almacen["_id"], sku).count() unless almacen["despacho"] # No consideramos el stock en el almacen de despacho
    end

    return contador
  end

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
    puts "--------Obteniendo Stock de Almacen--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
              })
      puts "(Stock_de_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Stock de Almacen Obtenido--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1013"
      render json: {"error": ex.message}, status: 503 and return
    end
  end


  def aceptar_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Aceptando OC--------------"
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.post(url+"recepcionar/"+idoc.to_s,
              body:    {
                      id: idoc
                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Aceptar_OC)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      if json.count() > 1
        render json: {"error": "Error2: se retornó más de una OC para el mismo id"}, status: 503 and return
      elsif !json[0]["proveedor"]
        render json: {"error": "Error: No se pudo recibir la OC"}, status: 503 and return
      end
      localOc = Oc.find_by idoc: idoc
      localOc.estado = "aceptada"
      localOc.save!
      puts "--------OC Aceptada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end



  def rechazar_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Rechazando OC--------------"
      puts idoc.to_s
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.post(url+"rechazar/"+idoc.to_s,
              body: {
                rechazo: 'No tenemos stock para el sku solicitado'
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Rechazar_OC)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error3: se retornó más de una OC para el mismo id" and return
      end
      localOc = Oc.find_by idoc: idoc.to_s
      localOc.estado = "rechazada"
      localOc.save!
      puts "--------OC Rechazada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end



  def lista_de_almacenes()
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Lista de Almacenes--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.get(url+"almacenes",
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
              })
      puts "(Lista_de_Almacenes)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Lista de Almacenes Obtenida--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1014"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def mover_producto_almacen(idProducto, almacenDestino)

    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Moviendo Producto de Bodega--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.post(url+"moveStock",
              body: {
                productoId: idProducto,
                almacenId: almacenDestino,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+almacenDestino)
              })
      puts "(Mover_Producto_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Producto de Bodega Movido--------------"
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1010"
      render json: {"error": ex.message}, status: 503 and return
    end
  end


  def get_array_productos_almacen(almacenid, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Productos por SKU del Almacen--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?"+"almacenId="+almacenid+"&"+'sku='+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenid+sku.to_s)
              })
      puts "(Array_Producto_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Productos Obtenidos por SKU del Almacen--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1011"
      render json: {"error": ex.message}, status: 503 and return
    end
  end



  # ----------------------------------------------------------------------------
  # ------------------------------Fábrica---------------------------------------
  # ----------------------------------------------------------------------------

  def cuentaFabrica()
    require 'httparty'
    puts "--------Obteniendo Cuenta Fabrica--------------"
    url = "http://integracion-2016-prod.herokuapp.com/bodega/fabrica/getCuenta"
    result = HTTParty.get(url,
            headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET')
              })
    puts "(Cuenta_Fabrica)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)
    puts "--------Cuenta Fabrica Obtenida--------------"
    return json['cuentaId'] #TODO: Revisar si es json[0] o solo json
  end


    # ----------------------------------------------------------------------------
    # ------------------------------Despachos---------------------------------------
    # ----------------------------------------------------------------------------


  def despacharInternacional(idfactura, factura)
    oc = Oc.find_by idfactura: idfactura
    sku = oc['sku']
    qty = oc['cantidad']
    precio = Item.find(sku).Precio_Unitario
    idoc = oc['idoc']
    almacenes = lista_de_almacenes()
    itemsDespachados = 0
    almacenes.each do |almacen|
      unless almacen['despacho']
        return if itemsDespachados == qty
        productos = get_array_productos_almacen(almacen['_id'], sku)
        productos.each do |producto|
          return if itemsDespachados == qty
          mover_a_despacho(producto) #TODO: IMPLEMENTAR FUNCION
          # despachar_producto(producto, almacenClienteId, idoc, precio) #TODO: IMPLEMENTAR FUNCION
          itemsDespachados += 1
        end
      end
    end
    oc["estado"] = "despachada"
    oc.save!
    return true
  end

  def despachar(idfactura, factura) #TODO: Revisar si este método va aquí
    oc = Oc.find_by idfactura: idfactura
    sku = oc['sku']
    qty = oc['cantidad']
    precio = Item.find(sku).Precio_Unitario
    idoc = oc['idoc']
    grupo = get_grupo_by_id(factura['cliente'])
    almacenClienteId = get_almacen_id(grupo)
    almacenes = lista_de_almacenes()
    itemsDespachados = 0
    almacenes.each do |almacen|
      unless almacen['despacho']
        return if itemsDespachados == qty
        productos = get_array_productos_almacen(almacen['_id'], sku)
        productos.each do |producto|
          return if itemsDespachados == qty
          mover_a_despacho(producto) #TODO: IMPLEMENTAR FUNCION
          despachar_producto(producto, almacenClienteId, idoc, precio) #TODO: IMPLEMENTAR FUNCION
          itemsDespachados += 1
        end
      end
    end
    oc["estado"] = "despachada"
    oc.save!
    return true
  end

  def mover_a_despacho(producto)
    require 'httparty'
    idDespacho = $despachoid
    idProducto = producto['_id']

    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Moviendo Producto a Despacho--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.post(url+"moveStock",
              body: {
                productoId: idProducto,
                almacenId: idDespacho
              }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+idDespacho)
              })
      puts "(Mover_a_Despacho)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Producto Movido a Despacho--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1009: " + ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def despachar_producto(producto, almacenClienteId, idoc, precio)
    require 'httparty'
    idProducto = producto['_id']

    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Despachando Producto a Cliente B2B--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.post(url+"moveStockBodega",
              body: {
                productoId: idProducto,
                almacenId: almacenClienteId,
                oc: idoc,
                precio: precio.to_i
              }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+almacenClienteId)
              })
      puts "(Despachar_Producto)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Producto Despachado a Cliente B2B--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1010"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def get_array_productos_almacen(almacenid, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Productos por SKU del Almacen--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?"+"almacenId="+almacenid+"&"+'sku='+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenid+sku.to_s)
              })
      puts "(Array_Producto_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Productos Obtenidos por SKU del Almacen--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1011"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

end
